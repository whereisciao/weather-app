class WeatherRequest
  attr_reader :current_temp, :current_high_temp, :current_low_temp, :location, :daily_forecast

  def initialize(location:)
    @location = location
  end

  def perform
    geocode_results = Geocoder.search(location)

    if geocode_results.count == 1
      lat, lon = geocode_results.first.coordinates
      response = weather_source.one_call(lat: lat, lon: lon)

      set_weather_attributes(response)
    end
  end

  private

  def weather_source
    @weather_source ||= OpenWeatherMap.new(api_key: ENV["OPEN_WEATHER_MAP_API"])
  end

  def set_weather_attributes(response)
    @current_temp = response.dig("current", "temp")
    @current_high_temp = response.dig("daily", 0, "temp", "max")
    @current_low_temp = response.dig("daily", 0, "temp", "min")
    @daily_forecast = response["daily"].map do |daily|
      {
        temp: daily["temp"].slice("min", "max"),
        summary: daily["summary"],
        weather: daily["weather"]
      }
    end
  end
end
