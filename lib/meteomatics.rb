class Meteomatics
  include HTTParty
  base_uri "api.meteomatics.com"

  def initialize(username: nil, password: nil)
    @options = {
      basic_auth: {
        username: username || ENV["METEOMATICS_USERNAME"],
        password: password || ENV["METEOMATICS_PASSWORD"]
      }
    }
  end

  def current(geocoordinates)
    parameters = [
      "t_2m:F",
      "t_2m:C"
    ]

    path = [
      Time.now.utc.iso8601,
      parameters.join(","),
      geocoordinates.join(","),
      "json"
    ]

    self.class.get("/#{path.join("/")}", @options)
  end
end
