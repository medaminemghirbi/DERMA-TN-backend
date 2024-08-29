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