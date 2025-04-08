class WeatherController < ApplicationController
  def show
    @request = WeatherRequest.new(location: params[:query])
    @request.perform
  end
end
