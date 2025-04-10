# WeatherRequest retrieves a location's place data then uses it to fetch the weather forecast.
class WeatherRequest
  # Generic Error for Weather Source issues
  class LocationNotFound < StandardError; end

  # Data Object to store forecast data.
  Forecast = Data.define(:timestamp, :summary, :high_temp, :low_temp, :weather, :temp, :wind_speed)

  # Duration of cache lifespan
  CACHE_TTL = 30.minutes

  # @return [String]
  #   The location to retrieve weather forecast.
  attr_reader :location

  # @return [String]
  #   The location's formatted address
  attr_reader :formatted_address

  # @return [Float]
  #   Latitude of the first geocoded result
  attr_reader :lat

  # @return [Float]
  #   Longitude of the first geocoded result
  attr_reader :lon

  # @return [Hash]
  #   Forecast data from weather source
  attr_reader :weather_response

  # @return [WeatherRequest::Forecast]
  #   Current weather forecast
  attr_reader :current_forecast

  # @return [Array<WeatherRequest::Forecast>]
  #   Array of daily weather forecast for the next 8 days, includes the current day.
  attr_reader :daily_forecasts

  def initialize(location:)
    @location = location
  end

  # Locations with a geocode result is valid enough to attempt to fetch the weather forecast
  def valid?
    geocode_result.present? && (geocode_result.types.include?("locality") || geocode_result.types.include?("street_address"))
  end

  # Given a location, get the geocode data, fetch weather forecast, then ingest the data.
  def perform
    return false unless valid?

    @lat, @lon = geocode_result.coordinates
    @formatted_address = geocode_result.formatted_address

    @weather_response = fetch_or_request_weather_forecast
    set_weather_attributes(weather_response)
  end

  # Save the first geocode result for a given location. This list is sorted by best match.
  def geocode_result
    @geocode_result ||= Geocoder.search(location).first
  end

  # Indicates if the cache is hit. Value is set in fetch_or_request_weather_forecast.
  def cache_hit?
    @cache_hit || false
  end

  # Builds the cache_key used by Rails.cache. Results are cached by zipcode, then falls back on place_id if precision is approx.
  def cache_key
    @cache_key ||= if geocode_result.postal_code.present?
      "weather_#{geocode_result.postal_code.parameterize}"
    elsif geocode_result.precision == "APPROXIMATE"
      "place_id__#{geocode_result.place_id}"
    end
  end

  private

  # Fetches the weather results either from the cache or from the weather source.
  def fetch_or_request_weather_forecast
    if cache_key.present?
      @cache_hit = Rails.cache.exist?(cache_key)

      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
        request_weather_forecast
      end
    else
      request_weather_forecast
    end
  end

  # Requests the forecast from the weather source.
  def request_weather_forecast
    response = weather_source.one_call(lat: lat, lon: lon)

    if response.success? && !(response.body.nil? || response.body.empty?)
      response.parsed_response
    end

  rescue Exception => error
    Sentry.capture_exception(error)

    raise LocationNotFound.new(error.message)
  end

  # Weather data vendor.
  def weather_source
    @weather_source ||= OpenWeatherMap.new(api_key: ENV["OPEN_WEATHER_MAP_API"])
  end

  # Transform weather data into Forecast
  def set_weather_attributes(response)
    return false if response.blank?

    @current_forecast = Forecast.new(
      timestamp: Time.zone.today,
      temp: response.dig("current", "temp"),
      high_temp: response.dig("daily", 0, "temp", "max"),
      low_temp: response.dig("daily", 0, "temp", "min"),
      summary: nil,
      weather: response.dig("current", "weather"),
      wind_speed: response.dig("current", "wind_speed")
    )

    @daily_forecasts = response["daily"].map do |daily|
      temp_hash = daily["temp"].slice("min", "max")

      Forecast.new(
        timestamp: Time.at(daily["dt"]),
        temp: nil,
        high_temp: temp_hash["max"],
        low_temp: temp_hash["min"],
        summary: daily["summary"],
        weather: daily["weather"],
        wind_speed: daily["wind_speed"]
      )
    end

    true
  end
end
