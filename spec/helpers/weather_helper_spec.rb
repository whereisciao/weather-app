require 'rails_helper'

RSpec.describe WeatherHelper, type: :helper do
  describe "#cache_status" do
    it "indicates when cache is missed" do
      report = instance_double("WeatherRequest", cache_hit?: false)

      expect(helper.cache_status(report)).to eq("Cache Missed")
    end

    it "indicates when cache is hit" do
      report = instance_double("WeatherRequest", cache_hit?: true, cache_key: "cache_key")

      expect(helper.cache_status(report)).to eq("Cache Hit - cache_key")
    end
  end

  describe "#format_temp" do
    it "formats temperature" do
      string = helper.format_temp(75.22)

      expect(string).to eq("75.22 &deg;F")
      expect(string).to be_html_safe
    end
  end

  describe "#weather_icon" do
    let(:report) { instance_double("WeatherReport", weather: [ { "icon" => "010" } ]) }

    it "builds an image tag" do
      expect(helper.weather_icon(report)).to eq(
        "<img src=\"https://openweathermap.org/img/wn/010@2x.png\" width=\"20\" height=\"20\" />"
      )
    end

    it "accepts a size param" do
      expect(helper.weather_icon(report, size: 50)).to eq(
        "<img src=\"https://openweathermap.org/img/wn/010@2x.png\" width=\"50\" height=\"50\" />"
      )
    end
  end
end
