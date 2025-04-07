class WeatherRequest
  Temperature = Data.define(:fahrenheit, :celsius)

  attr_reader :current_temperature, :location

  def initialize(location:)
    @location = location
  end

  def perform
    geocode_results = Geocoder.search(location)

    if geocode_results.count == 1
      current = weather_source.current(geocode_results.first.coordinates)

      @current_temperature = Temperature.new(
        fahrenheit: current["data"].first["coordinates"].first["dates"].first["value"],
        celsius: current["data"].last["coordinates"].first["dates"].first["value"],
      )
    end
  end

  private

  def weather_source
    @weather_source ||= Meteomatics.new
  end
end
