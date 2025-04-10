class WeatherController < ApplicationController
  rescue_from WeatherRequest::LocationNotFound, with: :location_not_found

  def show
    @request = WeatherRequest.new(location: params[:query])

    unless @request.perform
      location_not_found
    end
  end

  private

  def location_not_found
    if params[:query].present?
      flash[:alert] = "Sorry. We are unable to find the weather for '#{params[:query]}'. Please try another address."
    end

    redirect_to root_path
  end
end
