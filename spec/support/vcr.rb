require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock

  config.filter_sensitive_data("<OPEN_WEATHER_MAP_API>") do
    ENV['OPEN_WEATHER_MAP_API']
  end
end
