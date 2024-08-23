class Api::V1::DoctorsController < ApplicationController
  before_action :set_doctor, only: [:show, :destroy]
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


  def nearest
    user_location = [params[:latitude], params[:longitude]]
    @doctors = Doctor.near(user_location, 10) # 10 km radius
    #@doctors = Doctor.near([current_latitude, current_longitude], 10) # 10 km radius
    render json: @doctors
  end

  #************************* les fonctions private de classe ***********************#

  private

  def set_doctor
    @Doctor = Doctor.find(params[:id])
  end

end