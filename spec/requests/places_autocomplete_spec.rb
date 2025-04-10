require 'rails_helper'

RSpec.describe "PlacesAutocompletes", type: :request do
  describe "GET /index" do
    it "returns a list of places" do
      VCR.use_cassette("place_suggestions") do
        get "/autocomplete?input=123"

        expect(response.parsed_body).to match("suggestions" => be_kind_of(Array))
      end
    end
  end
end
