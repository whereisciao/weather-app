require 'rails_helper'

RSpec.describe PlacesAutocompleteRequest do
  describe "#perform" do
    it "fetches place suggestions" do
      VCR.use_cassette("place_suggestions", record: :all) do
        request = described_class.new(input: "123")

        expect(request.perform).to eq(true)
        expect(request.suggestions).to match_array([
          "1233 Andover Park East, Tukwila, WA",
          "1231 116th Avenue Northeast, Bellevue, WA",
          "1232 Andover Park West, Tukwila, WA",
          "123 Broadway, Seattle, WA",
          "12311 SE 166th St, Renton, WA"
        ])
      end
    end
  end
end
