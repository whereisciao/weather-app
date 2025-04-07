require 'rails_helper'

RSpec.describe WeatherRequest, type: :model do
  before { travel_to(Time.zone.local(2025, 4, 7, 00, 00, 00)) }
  after { travel_back }

  context "when a location is found" do
    it "returns the weather forcast" do
      VCR.use_cassette("weather_forcast") do
        request = WeatherRequest.new(location: "Seattle, WA")
        request.perform

        expect(request.current_temperature.fahrenheit).to eq(52.6)
        expect(request.current_temperature.celsius).to eq(11.5)
      end
    end
  end
end
