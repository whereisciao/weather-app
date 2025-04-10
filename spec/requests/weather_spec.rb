require 'rails_helper'

RSpec.describe "Weathers", type: :request do
  describe "GET /show" do
    subject(:show_request) { get "/location?query=#{location}" }

    before { VCR.insert_cassette("show_weather") }
    after { VCR.eject_cassette }

    context "when location is valid" do
      let(:location) { "2651 NE 49th St, Seattle, WA 98105" }

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

    context "when search is empty" do
      let(:location) { '' }

      it "should not show a flash" do
        show_request
        expect(response).to redirect_to(controller: :weather, action: :index)

        follow_redirect!
        expect(flash[:alert]).to be_nil
      end
    end

    context "when location is a Canadian Address" do
      include_context "cache enabled"

      let(:location) { "5880 Victoria Dr, Vancouver, BC V5P 3W9, Canada" }

      it "returns forecast" do
        show_request
        expect(response.body).to include("Today's Forecast")
        expect(response.body).to include("Daily Forecast")
      end

      it "caches the result" do
        expect {
          show_request
        }.to(change { Rails.cache.exist?("weather_v5p-3w9") }.from(false).to(true))
      end
    end

    context "when location is just a city" do
      let(:location) { "Seattle, WA" }

      it "doesn't cache results" do
        show_request
        expect(response.body).to include("Cache Missed")

        show_request
        expect(response.body).to include("Cache Missed")
      end
    end

    context "when geocoder fails to find a match" do
      let(:location) { "1 Santa Lane, North Pole" }

      it "gracely displays error message" do
        show_request

        expect(response).to redirect_to(controller: :weather, action: :index)

        follow_redirect!
        expect(response.body).to include("Sorry.")
      end
    end

    context "when weather API can't find the location" do
      let(:location) { "Seattle, WA" }

      before do
        stub_request(:get, /openweathermap/).
          to_return(
            status: 404,
            headers: { "Content-Type" => "application/json; charset=utf-8" },
            body: { "code" => 404, "message" => "Not Found" }.to_json
          )
      end

      it "displays a generic error" do
        show_request

        expect(response).to redirect_to(controller: :weather, action: :index)

        follow_redirect!
        expect(flash[:alert]).to be_present
        expect(response.body).to include("We are unable to find the weather")
      end
    end

    context "when weather API returns 401" do
      let(:location) { "Seattle, WA" }

      before do
        stub_request(:get, /openweathermap/).
          to_return(
            status: 401,
            headers: { "Content-Type" => "application/json; charset=utf-8" },
            body: {
              "cod": 401,
              "message": "Please note that using One Call 3.0 requires a separate subscription to the One Call by Call plan. Learn more here https://openweathermap.org/price. If you have a valid subscription to the One Call by Call plan, but still receive this error, then please see https://openweathermap.org/faq#error401 for more info."
            }.to_json
          )
      end

      it "displays a generic error" do
        show_request

        expect(response).to redirect_to(controller: :weather, action: :index)

        follow_redirect!
        expect(response.body).to include("We are unable to find the weather")
      end

      it "captures error to Sentry" do
        allow(Sentry).to receive(:capture_exception)

        show_request

        expect(Sentry).to have_received(:capture_exception)
      end
    end
  end
end
