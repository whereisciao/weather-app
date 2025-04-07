require 'rails_helper'

RSpec.describe Meteomatics do
  let(:client) { described_class.new }
  let(:geocoordinate) { [ 47.4799078, -122.2034496 ] }

  before { travel_to(Time.zone.local(2025, 4, 7, 00, 00, 00)) }
  after { travel_back }

  describe ".current" do
    it "fetches the current weather" do
      VCR.use_cassette("current_weather") do
        response = client.current(geocoordinate)
        expect(response).to be_present
      end
    end
  end

  describe ".forecast" do
    it "fetches future dates" do
      VCR.use_cassette("forecast", record: :all) do
        response = client.forecast(geocoordinate, days: 8)
        expect(response).to be_present
      end
    end
  end
end
