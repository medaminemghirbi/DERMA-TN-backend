require 'yaml'

class Api::V1::DoctorsController < ApplicationController
  before_action :authorize_request
    def  index
      render json: Doctor.current.all, each_serializer: Api::V1::DoctorSerializer
    end

  def show
    @Doctor = Doctor.find(params[:id])
    render json: @Doctor
  end


  def destroy
    @Doctor = Doctor.find(params[:id])
    @Doctor.update(is_archived: true)
  end

  def unique_locations
    # Load the YAML file and access the 'gouvernements' key
    gouvernements = YAML.load_file(Rails.root.join('app', 'services', 'locations.yml'))['gouvernements']
  
    # Render the array directly as JSON
    if gouvernements
      render json: gouvernements, status: :ok
    else
      render json: { errors: 'No data found' }, status: :not_found
    end
  end
  
  def  get_doctors_by_locations
    @doctors = Doctor.where(location: params[:location])
    render json: @doctors
  end

  def activate_compte
    @doctor = Doctor.find(params[:id])

    if @doctor.update(email_confirmed: true, confirm_token: nil)
      render json: { message: "Account successfully activated.", doctor: @doctor }, status: :ok
    else
      render json: { errors: @doctor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def nearest
    user_location = [params[:latitude], params[:longitude]]
    @doctors = Doctor.near(user_location, 10) # 10 km radius
    #@doctors = Doctor.near([current_latitude, current_longitude], 10) # 10 km radius
    render json: @doctors
  end

end