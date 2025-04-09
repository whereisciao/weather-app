class WeatherController < ApplicationController
  def show
    @request = WeatherRequest.new(location: params[:query])

    unless @request.perform
      message = "Sorry. We are unable to find the weather for '#{params[:query]}' as it is an incomplete US Address."
      redirect_to root_path, alert: message
    end
  end
end
