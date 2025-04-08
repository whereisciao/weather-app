class WeatherRequest
  attr_reader :location,
    :lat,
    :lon,
    :weather_response,
    :current_forecast,
    :daily_forecasts

  Forecast = Data.define(:timestamp, :summary, :high_temp, :low_temp, :weather, :temp)

  def initialize(location:)
    @location = location
  end

  def valid?
    geocode_results.count >= 1
  end

  def perform
    return false unless valid?

    @lat, @lon = geocode_results.first.coordinates
    @weather_response = weather_source.one_call(lat: lat, lon: lon)

    set_weather_attributes(weather_response)

    true
  end

  def geocode_results
    @geocode_results ||= Geocoder.search(location)
  end

  private

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
