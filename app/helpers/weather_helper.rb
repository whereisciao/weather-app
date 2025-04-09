module WeatherHelper
  # Indicates if the results were pulled from cache
  def cache_status(report)
    if @request.cache_hit?
      "Cache Hit - #{@request.cache_key}"
    else
      "Cache Missed"
    end
  end
end
