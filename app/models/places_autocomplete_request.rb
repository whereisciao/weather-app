class PlacesAutocompleteRequest
  attr_reader :input, :suggestions, :response

  REGION_CODES = [ "us" ].freeze

  def initialize(input:)
    @input = input
  end

  def perform
    request = Google::Apis::PlacesV1::GoogleMapsPlacesV1AutocompletePlacesRequest.new(
      included_region_codes: REGION_CODES,
      input: input
    )
    @response = service.autocomplete_place(request)
    true
  end

  def suggestions
    response.suggestions.map do |suggestion|
      suggestion.place_prediction.text.text
    end
  end

  private

  def service
    @service ||= Google::Apis::PlacesV1::MapsPlacesService.new.tap { |maps_places_service|
      maps_places_service.key = ENV["GOOGLE_MAPS_API"]
    }
  end
end
