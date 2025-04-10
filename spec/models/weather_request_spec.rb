require 'rails_helper'

RSpec.describe WeatherRequest, type: :model do
  describe "#perform" do
    context "when a location is found" do
      include_context "cache enabled"

      before { VCR.insert_cassette("show_weather") }

      after { VCR.eject_cassette }

      it "returns the current forecast" do
        request = WeatherRequest.new(location: "2651 NE 49th St, Seattle, WA 98105")
        request.perform

        expect(request.current_forecast).to be_kind_of(WeatherRequest::Forecast)
      end

      it "returns forecast for the next several days" do
        request = WeatherRequest.new(location: "2651 NE 49th St, Seattle, WA 98105")
        request.perform

        expect(request.daily_forecasts.size).to eq(8)
        expect(request.daily_forecasts).to all(be_kind_of(WeatherRequest::Forecast))
      end

      it "caches the results by postal code" do
        expect {
          request = WeatherRequest.new(location: "2651 NE 49th St, Seattle, WA 98105")
          request.perform
        }.to(change { Rails.cache.exist?("weather_98105") }.from(false).to(true))
      end

      it "caches results by town" do
        expect {
          request = WeatherRequest.new(location: "Seattle, WA")
          request.perform
        }.to(change { Rails.cache.exist?("place_id__ChIJVTPokywQkFQRmtVEaUZlJRA") }.from(false).to(true))
      end
    end
  end
end
