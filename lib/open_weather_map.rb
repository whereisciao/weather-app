class OpenWeatherMap
  include HTTParty
  base_uri "https://api.openweathermap.org"

  DEFAULT_UNITS = "imperial".freeze
  DEFAULT_EXCLUDED = "minutely,hourly".freeze

  attr_reader :api_key

  def initialize(api_key:)
    @api_key = api_key
  end

  def one_call(lat:, lon:, units: DEFAULT_UNITS, exclude: DEFAULT_EXCLUDED)
    options = {
      query: {
        lat: lat,
        lon: lon,
        appid: api_key,
        units: units,
        exclude: exclude
      }
    }

    response = self.class.get("/data/3.0/onecall", options)

    if response.success?
      response
    else
      raise response["message"]
    end
  end
end
