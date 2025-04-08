require 'rails_helper'

RSpec.describe OpenWeatherMap do
  let(:client) { described_class.new(api_key: ENV["OPEN_WEATHER_MAP_API"]) }

  describe "#one_call" do
    subject(:request) { client.one_call(lat: lat, lon: lon) }

    let(:lat) { 47.479908 }
    let(:lon) { -122.20345 }

    context "when request is successful" do
      before { VCR.insert_cassette('seattle_weather') }
      after { VCR.eject_cassette }

      it "returns several current weather details" do
        expect(request["current"]).to include(
                                        "temp" => kind_of(Float),
                                        "weather" => kind_of(Array)
                                      )
      end

      it "returns forecast for the next 8 days" do
        expect(request["daily"].size).to eq(8)
        expect(request["daily"]).to all(include(
                                          "temp" => hash_including("max", "min"),
                                          "weather" => kind_of(Array)
                                        ))
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
