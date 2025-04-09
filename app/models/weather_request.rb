class WeatherRequest
  # Generic Error for Weather Source issues
  class LocationNotFound < StandardError; end

  Forecast = Data.define(:timestamp, :summary, :high_temp, :low_temp, :weather, :temp)
  CACHE_TTL = 30.minutes

  attr_reader :location,
    :lat,
    :lon,
    :weather_response,
    :current_forecast,
    :daily_forecasts

  def initialize(location:)
    @location = location
  end

  def valid?
    geocode_result.present?
  end

  def perform
    return false unless valid?

    @lat, @lon = geocode_result.coordinates

    @weather_response = fetch_or_request_weather_forecast
    set_weather_attributes(weather_response)
  end

  def geocode_result
    @geocode_results ||= Geocoder.search(location).first
  end

  def cache_hit?
    @cache_hit || false
  end

  def cache_key
    @cache_key ||= "weather_#{geocode_result.postal_code}" if geocode_result.postal_code.present?
  end

  private

  def fetch_or_request_weather_forecast
    if geocode_result.postal_code.present?
      @cache_hit = Rails.cache.exist?(cache_key)

      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
        request_weather_forecast
      end
    else
      request_weather_forecast
    end
  end

  def request_weather_forecast
    response = weather_source.one_call(lat: lat, lon: lon)

    if response.success? && !(response.body.nil? || response.body.empty?)
      response.parsed_response
    end

  rescue Exception => error
    raise LocationNotFound.new(error.message)
  end

  def weather_source
    @weather_source ||= OpenWeatherMap.new(api_key: ENV["OPEN_WEATHER_MAP_API"])
  end

  def set_weather_attributes(response)
    return false if response.blank?

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

    true
  end
end
