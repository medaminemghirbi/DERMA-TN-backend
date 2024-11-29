class Api::Mobile::DoctorsController < ApplicationController
  before_action :authorize_request

  def nearest
    location = params[:location]
    radius = params[:radius] || 20

    coordinates = Geocoder.coordinates(location)

    if coordinates.nil?
      # Example fallback locations
      fallback_locations = ["#{location} city", "near #{location}"]
      coordinates = fallback_locations.map { |loc| Geocoder.coordinates(loc) }.compact.first
    end

    if coordinates
      @doctors = Doctor.near(coordinates, radius, units: :km)
      render json: @doctors, methods: [:user_image_url]
    else
      render json: {error: "Location not found"}, status: :unprocessable_entity
    end
  end
end