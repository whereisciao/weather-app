class WeatherController < ApplicationController
  def show
    @request = WeatherRequest.new(location: params[:query])

    if @request.valid?
      @request.perform
    else
      message = "'#{params[:query]}' is an incomplete US Address. #{@request.errors.full_messages.join(", ")}."
      redirect_to root_path, alert: message
    end
  end
end
