require 'rails_helper'

RSpec.describe "Weathers", type: :request do
  describe "GET /show" do
    subject(:show_request) { get "/location?query=#{query}" }

    before { VCR.insert_cassette("show_weather", record: :all) }
    after { VCR.eject_cassette }

    context "when location is valid" do
      let(:query) { "2651 NE 49th St, Seattle, WA 98105" }

      it "returns weather for a valid location" do
        show_request

        expect(response).to render_template(:show)
        expect(response.body).to include("Today's Forecast")
        expect(response.body).to include("Daily Forecast")
      end

      it "returns cache information" do
        show_request
        expect(response.body).to include("Cache Missed")
      end

      context "when cache is hit" do
        include_context "cache enabled"

        it "returns forecast for existing zipcode" do
          # Fetch another address with a similar zipcode
          get "/location?query=2901 NE Blakeley St, Seattle, WA 98105"

          show_request
          expect(response.body).to include("Cache Hit")
        end

        it "misses the cache if the zipcode is not found" do
          # Fetches an address with a different zipcode
          get "/location?query=1 Apple Park Way, Cupertino, CA 95014"

          show_request
          expect(response.body).to include("Cache Missed")
        end
      end
    end

    context "when location is just a city" do
      let(:query) { "Seattle, WA" }

      it "doesn't cache results" do
        show_request
        expect(response.body).to include("Cache Missed")

        show_request
        expect(response.body).to include("Cache Missed")
      end
    end

    context "when geocoder fails" do
      let(:query) { "1 Santa Lane, North Pole" }

      it "gracely displays error message" do
        show_request

        expect(response).to redirect_to(controller: :weather, action: :index)

        follow_redirect!
        expect(response.body).to include("Sorry.")
      end
    end
  end
end
