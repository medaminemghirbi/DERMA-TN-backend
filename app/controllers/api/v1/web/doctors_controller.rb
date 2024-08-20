class Api::V1::Web::DoctorsController < ApplicationController
  def nearest
    user_location = [params[:latitude], params[:longitude]]
    @doctors = Doctor.near(user_location, 10) # 10 km radius
    #@doctors = Doctor.near([current_latitude, current_longitude], 10) # 10 km radius
    render json: @doctors
  end


end