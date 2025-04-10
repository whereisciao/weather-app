# README

This Weather App was designed to fulfill a coding assigment within a reasonable set time. Given a location, fetch the weather forecast. Cache results for 30 minutes by zip code.

<img width="1203" alt="image" src="https://github.com/user-attachments/assets/887c36e4-d613-413c-995d-ed659f148149" />


# Technical approach
* Given the requirements, it was not explicity necessary to create a data model to data to a database. This application was designed with a plain old Ruby object.

* `Rails.cache` was used to cache data. In development, a memory cache is used. In production, the application is configured to use Solid Cache, which is a databased-back Active Support cache.

* Latitude and longitude coordinates are required to retrieve weather data. The `geocoder` gem is a robust geocoding library for converting street addresses into coordinates. In production, a Redis cache should be setup. Redis was left off to allow another developer to start this app easier.

* Sentry.io was added for application monitoring.

* To save on weather API requests, additional caching was added to save on municipalities and cities.

# Getting Started

1. Gather API keys. An Open Weather Map API Key is required to request weather data. A key should be provided by your contact, or you could register your own by visiting https://openweathermap.org/. A `GOOGLE_MAPS_API` is required for autocomplete. A key should be provided by your contact, or you could register your own by following [Google's Get API Key](https://developers.google.com/maps/documentation/places/web-service/get-api-key) instructions.

2. Copy `.env.example` and rename the file to `.env`. Set `OPEN_WEATHER_MAP_API` and `GOOGLE_MAPS_API` from step 1.

3. Run `bundle install` to install dependencies.

4. Run `rails server` to start the server.

5. Visit http://localhost:3000 to demo.

# Classes to note

`WeatherRequest` - The plain old ruby object responsible for geocoding a location, fetching weather data, and transforming the data into a `Forecast` to display.

`WeatherRequest::Forecast` - Data class for storing weather data.

`OpenWeatherMap` - A Ruby API wrapper around OpenWeather's Onecall API. The API returns essential weather data, both short-term and long-term forecast.

`PlacesAutocompleteRequest` - Request class for fetching place suggestions.
