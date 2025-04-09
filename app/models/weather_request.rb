class WeatherRequest
  include ActiveModel::Model

  Forecast = Data.define(:timestamp, :summary, :high_temp, :low_temp, :weather, :temp)
  CACHE_TTL = 30.minutes

  attr_accessor :location

  attr_reader :location,
    :parsed_address,
    :lat,
    :lon,
    :weather_response,
    :current_forecast,
    :daily_forecasts

  validates :postal_code, presence: true
  validates :geocode_results, length: { minimum: 1 }, if: -> { postal_code.present? }

  def postal_code
    return @postal_code if defined?(@postal_code)

    @postal_code = StreetAddress::US.parse(location)&.postal_code
  end

  def perform
    return false unless valid?

    @weather_response = fetch_weather_forecast(geocode_results.first)

    set_weather_attributes(weather_response)

    true
  end

  def geocode_results
    @geocode_results ||= Geocoder.search(location)
  end

  def cache_hit?
    @cache_hit
  end

  private

  def fetch_weather_forecast(geocode_result)
    @lat, @lon = geocode_result.coordinates

    cache_key = "weather_#{geocode_result.postal_code}"

    @cache_hit = Rails.cache.exist?(cache_key)

    Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
      response = weather_source.one_call(lat: lat, lon: lon)

      if response.success? && !(response.body.nil? || response.body.empty?)
        response.parsed_response
      end
    end
  end

  def weather_source
    @weather_source ||= OpenWeatherMap.new(api_key: ENV["OPEN_WEATHER_MAP_API"])
  end

  def set_weather_attributes(response)
    @current_forecast = Forecast.new(
      timestamp: Time.zone.today,
      temp: response.dig("current", "temp"),
      high_temp: response.dig("daily", 0, "temp", "max"),
      low_temp: response.dig("daily", 0, "temp", "min"),
      summary: nil,
      weather: response.dig("current", "weather")
    )

    @daily_forecasts = response["daily"].map do |daily|
      temp_hash = daily["temp"].slice("min", "max")

      Forecast.new(
        timestamp: Time.at(daily["dt"]),
        temp: nil,
        high_temp: temp_hash["max"],
        low_temp: temp_hash["min"],
        summary: daily["summary"],
        weather: daily["weather"]
      )
    end
  end
end
