require 'rails_helper'

RSpec.describe OpenWeatherMap do
  let(:client) { described_class.new(api_key: ENV["OPEN_WEATHER_MAP_API"]) }

  describe "#one_call" do
    subject(:request) { client.one_call(lat: lat, lon: lon) }

    let(:lat) { 47.479908 }
    let(:lon) { -122.20345 }

    context "when request is successful" do
      before(:example) do
        travel_to Time.zone.local(2025, 4, 8, 12, 0, 0)

        VCR.insert_cassette('seattle_weather')
      end

      after(:example) do
        travel_back

        VCR.eject_cassette
      end

      it "returns current weather by lat/lon" do
        expect(request).to be_success
      end
    end

    context "when request is unsuccessful" do
      let(:client) { described_class.new(api_key: "BAD_KEY") }

      it "raises the error message" do
        VCR.use_cassette("unauthorize_request") do
          expect { request }.to raise_error(RuntimeError, /One Call 3.0 requires a separate subscription/)
        end
      end
    end
  end
end
