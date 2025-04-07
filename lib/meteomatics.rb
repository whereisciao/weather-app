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
    path = build_path(
      period: Time.now.utc.iso8601,
      weather_params: [ :temp_surface_fahrenheit, :temp_surface_celsius ],
      geocoordinates: geocoordinates
    )


    self.class.get(path, @options)
  end

  def forecast(geocoordinates, days_ahead:)
    period = [ Time.now, Time.now + days_ahead.days ].map(&:utc).map(&:iso8601).join("--")

    path = build_path(
      period: "#{period}:PT1H",
      weather_params: [ :temp_surface_fahrenheit, :temp_surface_celsius ],
      geocoordinates: geocoordinates
    )

    self.class.get(path, @options)
  end

  private

  def build_parameters(*parameter_keys)
     Meteomatics::PARAMETERS.values_at(*parameter_keys).join(",")
  end

  def build_path(period:, weather_params:, geocoordinates:)
    path = [
      period,
      build_parameters(*weather_params),
      geocoordinates.join(","),
      "json"
    ]

    "/#{path.join("/")}"
  end
end
