module WeatherHelper
  # Indicates if the results were pulled from cache
  def cache_status(report)
    if @request.cache_hit?
      "Cache Hit - #{@request.cache_key}"
    else
      "Cache Missed"
    end
  end

  # Formats fahrenheit by default. Could be change to Celsius
  def format_temp(degree)
    "#{degree} &deg;F".html_safe
  end

  def weather_icon(report, size: 20)
    if weather = report.weather.first
      image_tag("https://openweathermap.org/img/wn/#{weather["icon"]}@2x.png", size:)
    end
  end
end
