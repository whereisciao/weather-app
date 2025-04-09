# API class to interface with OpenWeather's One Call API.
class OpenWeatherMap
  include HTTParty
  base_uri "https://api.openweathermap.org"

  DEFAULT_UNITS = "imperial".freeze
  DEFAULT_EXCLUDED = "minutely,hourly".freeze

  attr_reader :api_key

  def initialize(api_key:)
    @api_key = api_key
  end

  # API call to OpenWeather One Call API. Designed to ensure easy migration from Dark Sky API.
  # https://openweathermap.org/api/one-call-3
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
      # Basic Error handling. Should expand to cover documented error codes.
      raise response["message"]
    end
  end
end
