require 'rails_helper'

RSpec.describe "PlacesAutocompletes", type: :request do
  describe "GET /index" do
    subject(:get_request) { get "/autocomplete?input=123" }

    it "returns a list of places" do
      VCR.use_cassette("place_suggestions") do
        get_request

        expect(response.parsed_body).to match("suggestions" => be_kind_of(Array))
      end
    end

    context "when Google::Apis::ClientError" do
      before do
        stub_request(:post, /places\.googleapis\.com/).
          to_return(
            status: 403,
            headers: { "Content-Type" => "application/json; charset=utf-8" },
            body: {
              "error": {
                "code": 403,
                "message": "Method doesn't allow unregistered callers (callers without established identity). Please use API Key or other form of API consumer identity to call this API.",
                "status": "PERMISSION_DENIED"
              }
            }.to_json
          )
      end

      it "returns an empty" do
        get_request

        expect(response).to be_successful
        expect(response.parsed_body).to be_empty
      end
    end
  end
end
