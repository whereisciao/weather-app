require 'rails_helper'

RSpec.describe WeatherRequest, type: :model do
  context "when a location is found" do
    before { VCR.insert_cassette("weather_forcast") }

    after { VCR.eject_cassette }

    it "returns the current forecast" do
      request = WeatherRequest.new(location: "Seattle, WA")
      request.perform

      expect(request.current_temp).to be_present
      expect(request.current_high_temp).to be_present
      expect(request.current_low_temp).to be_present
    end

    it "returns forecast for the next several days" do
      request = WeatherRequest.new(location: "Seattle, WA")
      request.perform

      expect(request.daily_forecast.size).to eq(8)
      expect(request.daily_forecast).to all(include(
                                                      temp: hash_including("min", "max"),
                                                      summary: be_kind_of(String),
                                                      weather: be_kind_of(Array)
                                                   ))
    end
  end
end
