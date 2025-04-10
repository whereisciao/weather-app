require 'rails_helper'

RSpec.describe "PlacesAutocompletes", type: :request do
  describe "GET /index" do
    it "returns a list of places" do
      VCR.use_cassette("place_suggestions") do
        get "/autocomplete?input=123"

        expect(response.parsed_body).to eq({
            "suggestions" => [
              "1233 Andover Park East, Tukwila, WA, USA",
              "1231 116th Avenue Northeast, Bellevue, WA, USA",
              "1232 Andover Park West, Tukwila, WA, USA",
              "123 Broadway, Seattle, WA, USA",
              "12311 SE 166th St, Renton, WA, USA"
            ]
          })
      end
    end
  end
end
