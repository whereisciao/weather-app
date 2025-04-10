module WeatherHelper
  # Indicates if the results were pulled from cache
  def cache_status(report)
    if report.cache_hit?
      "Cache Hit - #{report.cache_key}"
    else
      "Cache Missed"
    end
  end

  # Formats fahrenheit by default. Could be change to Celsius
  def format_temp(degree)
    "#{degree} &deg;F".html_safe
  end

  # Builds image tag for OpenWeather icons
  def weather_icon(report, size: 20)
    if weather = report.weather.first
      image_tag("https://openweathermap.org/img/wn/#{weather["icon"]}@2x.png", size:)
    end
  end
end
