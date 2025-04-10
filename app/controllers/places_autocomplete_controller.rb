class PlacesAutocompleteController < ApplicationController
  def get
    @request = PlacesAutocompleteRequest.new(input: params[:input])
    @request.perform

    render json: {
      suggestions: @request.suggestions
    }
  end
end
