require 'yaml'

class Api::V1::DoctorsController < ApplicationController
  before_action :authorize_request, except: [:unique_locations]
  def getDoctorStatistique
    @consultations = Consultation.current.where(doctor_id: params[:doctor_id]).count
    @blogs = Blog.current.where(doctor_id: params[:doctor_id]).count
    @ia_usages =  DoctorUsage.current.where(doctor_id: params[:doctor_id])
    total_ia_usage_count = @ia_usages.sum(:count)
    render json: {
      consultation: @consultations,
      blogs: @blogs,
      ia_usage: total_ia_usage_count
    }
  end
  def index
    doctors = Doctor.current.all
  
    render json: doctors.as_json(
      methods: [:user_image_url]
    )
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


  def upgrade_doctor_plan
    @doctor = Doctor.find_by(id: params[:id])
    if @doctor
      # Check if the plan is 'custom'
      if params[:plan] == 'custom'
        # Update plan and custom_plan if plan is 'custom'
        @doctor.update(plan: params[:plan], custom_limit: params[:customLimit])
      else
        # Only update the plan if it's not 'custom'
        @doctor.update(plan: params[:plan])
      end
  
      render json: { success: true, message: 'Plan updated successfully' }
    else
      render json: { success: false, message: 'Doctor not found' }, status: :not_found
    end
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
    location = params[:location]
    radius = params[:radius] || 20
    coordinates = Geocoder.coordinates(location)
    if coordinates
      @doctors = Doctor.near(coordinates, radius, units: :km)
      render json: @doctors
    else
      render json: { error: 'Location not found' }, status: :unprocessable_entity
    end
  end


  def updatedoctorimage
    @user = User.find(params[:id])
    if @user.update(paramsimagefreelancer)
      render json: @user, methods: [:user_image_url]
    else
      render json: @user.errors, statut: :unprocessable_entity
    end
  end
  def updatedoctor
    @user = User.find(params[:id])
    
    if @user.update(post_params_doctor)

      render json: @user, methods: [:user_image_url]

    else
      render json: @user.errors, statut: :unprocessable_entity
    end
  end
  def updatepassword
    @user = User.find(params[:id])
                &.try(:authenticate, params[:password])
    if @user
      if params[:new_password] == params[:confirm_password]
        if @user.update(user_params)
          render json: { message: "Password successfully updated", user: @user }, methods: [:user_image_url], status: :ok
          Rails.logger.debug("Update failed due to: #{@user.errors.full_messages}")

        else
          render json: { errors: "fama chy" }
        end
  
      else
        render json: { error: "New password and confirmation do not match" }, status: :unprocessable_entity
      end
  
    else
      render json: { error: "Old password is incorrect" }, status: :unprocessable_entity
    end
  end
  
  private 
  def paramsimagefreelancer
    params.permit(:id, :avatar)
  end
  def post_params_doctor
    params.permit(:id, :website, :facebook, :twitter, :youtube, :linkedin)
  end
  def user_params
    params.permit(:password, :newPassword, :confirmPassword, :id)
  end
end