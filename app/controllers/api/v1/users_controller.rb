class Api::V1::UsersController < ApplicationController
    before_action :authorize_request, except: %i[:count_all_for_admin, :update_image_user, :update_location ]
    #************************* custom functionlity ***************************#
    
    def count_all_for_admin
      @apointements = Consultation.current.all.count
      @patients = Patient.current.all.count
      @blogs = Blog.current.all.count
      @doctors = Doctor.current.all.count
      @maladies = Maladie.current.all.count
      @scanned = DoctorUsage.sum(:count)

      render json: {
        apointements: @apointements,
        patients: @patients,
        blogs: @blogs,
        doctors: @doctors,
        maladies: @maladies,
        scanned: @scanned
      }
    end

    def update_location
      @user = User.find(params[:id])
      if @user.update(params_location_doctor)
        render json: @user, methods: [:user_image_url]
      else
        render json: @user.errors, statut: :unprocessable_entity
      end
    end
    def update_image_user
      @user = User.find(params[:id])
      if @user.update(params_image_user)
        render json: @user, methods: [:user_image_url]
      else
        render json: @user.errors, statut: :unprocessable_entity
      end
    end
    def update_email_notifications
      @user = User.find(params[:id])
      
      if @user.update(is_emailable: params[:is_emailable])
        render json: @user, methods: [:user_image_url]
      else
        render json: {
          status: 422,
          errors: @user.errors.full_messages  # Use @user.errors directly instead of @user.user_setting.errors
        }, status: :unprocessable_entity
      end
    end
    
  
    # Update system notification preference
    def update_system_notifications
      @user = User.find(params[:id])

      if @user.update(is_notifiable: params[:is_notifiable])
        render json: @user, methods: [:user_image_url]
      else
        render json: {
          status: 422,
          errors: @user.errors.full_messages  # Use @user.errors directly instead of @user.user_setting.errors
          }, status: :unprocessable_entity
      end
    end
  
    # Update SMS notification preference
    def update_sms_notifications
      @user = User.find(params[:id])

      if  @user.update(is_smsable: params[:is_smsable])
        render json: @user, methods: [:user_image_url]
      else
        render json: {
          status: 422,
          errors: @user.errors.full_messages  # Use @user.errors directly instead of @user.user_setting.errors
          }, status: :unprocessable_entity
      end
    end

    def update_uesr_informations
      @user = User.find(params[:id])
      if @user.update(params_informations_user)
        render json: @user, methods: [:user_image_url]
      else
        render json: @user.errors, statut: :unprocessable_entity
      end
    end
    #************************* les fonctions private de classe ***********************#
      private

      def params_image_user
        params.permit(:id, :avatar)
      end
      def params_informations_user
        params.permit(:id, :civil_status, :gender, :birthday)
      end
      def params_location_doctor
        params.permit(:id, :latitude, :longitude)
      end
      
end