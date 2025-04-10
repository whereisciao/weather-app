require 'rails_helper'

RSpec.describe PlacesAutocompleteRequest do
  describe "#perform" do
    it "fetches place suggestions" do
      VCR.use_cassette("place_suggestions", record: :all) do
        request = described_class.new(input: "123")

        expect(request.perform).to eq(true)
        expect(request.suggestions).to match_array([
          "1233 Andover Park East, Tukwila, WA, USA",
          "1231 116th Avenue Northeast, Bellevue, WA, USA",
          "1232 Andover Park West, Tukwila, WA, USA",
          "123 Broadway, Seattle, WA, USA",
          "12311 SE 166th St, Renton, WA, USA"
        ])
      end
    end
  end
end
