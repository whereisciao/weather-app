require 'rails_helper'

RSpec.describe "Weathers", type: :request do
  describe "GET /show" do
    context "with a valid location" do
      it "returns weather for a valid location" do
        VCR.use_cassette("show_weather", record: :all) do
          get "/location?query=2651 NE 49th St, Seattle, WA 98105"

          expect(response).to render_template(:show)
          expect(response.body).to include("Widget was successfully created.")
        end
      end
    end
  end
end
