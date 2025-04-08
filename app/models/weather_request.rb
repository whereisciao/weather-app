class WeatherRequest
  attr_reader :location,
    :parsed_address,
    :lat,
    :lon,
    :weather_response,
    :current_forecast,
    :daily_forecasts

  Forecast = Data.define(:timestamp, :summary, :high_temp, :low_temp, :weather, :temp)
  CACHE_TTL = 30.minutes

  def initialize(location:)
    @location = location
    @parsed_address = StreetAddress::US.parse(location)
  end

  def valid?
    parsed_address.postal_code.present? && geocode_results.count >= 1
  end

  def perform
    return false unless valid?

    geocode_result = geocode_results.first

    @lat, @lon = geocode_result.coordinates
    @weather_response = fetch_weather_forecast(lat: lat, lon: lon, postal_code: geocode_result.postal_code)

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

  def fetch_weather_forecast(lat:, lon:, postal_code:)
    cache_key = "weather_#{postal_code}"

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
