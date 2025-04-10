Geocoder.configure(
  lookup: :google,
  api_key: ENV["GOOGLE_MAPS_API"],

  # Geocode searches should also be cached. Redis is a good option.
  cache: Redis.new,
  cache_options: {
    expiration: 1.day
  }
)
