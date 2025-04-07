class Meteomatics
  include HTTParty
  base_uri "api.meteomatics.com"

  PARAMETERS = {
    temp_surface_fahrenheit: "t_2m:F",
    temp_surface_celsius: "t_2m:C",
    weather_state: "weather_symbol_1h:idx"
  }

  def initialize(username: nil, password: nil)
    @options = {
      basic_auth: {
        username: username || ENV["METEOMATICS_USERNAME"],
        password: password || ENV["METEOMATICS_PASSWORD"]
      }
    }
  end

  def current(geocoordinates)
    path = [
      Time.now.utc.iso8601,
      build_parameters(:temp_surface_fahrenheit, :temp_surface_celsius),
      geocoordinates.join(","),
      "json"
    ]

    self.class.get("/#{path.join("/")}", @options)
  end

  def forecast(geocoordinates, days_ahead:)
    period = [ Time.now, Time.now + days_ahead.days ].map(&:utc).map(&:iso8601).join("--")

    path = [
      "#{period}:P1D",
      build_parameters(:temp_surface_fahrenheit, :temp_surface_celsius),
      geocoordinates.join(","),
      "json"
    ]

    self.class.get("/#{path.join("/")}", @options)
  end

  private

  def build_parameters(*parameter_keys)
     Meteomatics::PARAMETERS.values_at(*parameter_keys).join(",")
  end
end
