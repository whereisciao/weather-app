# Places Autocomplete Request
#
# Given a string input, a request is made to Google Places API for place suggestions.
class PlacesAutocompleteRequest
  # @return [String]
  #   Input string to search.
  attr_reader :input

  # @return [Array<String>]
  #   A list of suggestions from input string.
  attr_reader :suggestions

  # @return [Google::Apis::PlacesV1::GoogleMapsPlacesV1AutocompletePlacesResponse]
  #   Response object from Google Autocomplete Places.
  attr_reader :response

  # Region Code to limit suggestions
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

  rescue Google::Apis::ClientError => error
    Sentry.capture_exception(error)
  end

  # Extract suggestions from response. Transform strings into desired format. Filter for specific types of suggestions.
  def suggestions
    return [] if response.nil?

    response.suggestions.filter_map do |suggestion|
      place_prediction = suggestion.place_prediction

      if suggestion.place_prediction.types.include?("premise") || suggestion.place_prediction.types.include?("locality")
        place_prediction.text.text.sub(/\, USA\z/, "")
      end
    end
  end

  private

  # Build MapsPlacesService with API key.
  def service
    @service ||= Google::Apis::PlacesV1::MapsPlacesService.new.tap { |maps_places_service|
      maps_places_service.key = ENV["GOOGLE_MAPS_API"]
    }
  end
end
