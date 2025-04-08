require 'rails_helper'

RSpec.describe "Weathers", type: :request do
  describe "GET /show" do
    context "with a valid location" do
      subject(:show_request) { get "/location?query=2651 NE 49th St, Seattle, WA 98105" }

      before { VCR.insert_cassette("show_weather") }
      after { VCR.eject_cassette }

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
          get "/location?query=One Apple Park Way, Cupertino, CA 95014"

          show_request
          expect(response.body).to include("Cache Missed")
        end
      end
    end
  end
end
