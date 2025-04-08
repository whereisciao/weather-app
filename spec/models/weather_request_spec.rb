require 'rails_helper'

RSpec.describe WeatherRequest, type: :model do
  context "when a location is found" do
    before { VCR.insert_cassette("weather_forcast") }

    after { VCR.eject_cassette }

    it "returns the current forecast" do
      request = WeatherRequest.new(location: "Seattle, WA")
      request.perform

      expect(request.current_forecast).to be_kind_of(WeatherRequest::Forecast)
    end

    it "returns forecast for the next several days" do
      request = WeatherRequest.new(location: "Seattle, WA")
      request.perform

      expect(request.daily_forecasts.size).to eq(8)
      expect(request.daily_forecasts).to all(be_kind_of(WeatherRequest::Forecast))
    end
  end
end
