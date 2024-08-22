class Api::V1::UsersController < ApplicationController
    before_action :authorize_request, except: %i[:count_all_for_admin, :update_image_user ]
    #************************* custom functionlity ***************************#
    
    def count_all_for_admin
      @apointements = Consultation.current.all.count
      @patients = Patient.current.all.count
      @blogs = Blog.current.all.count
      render json: {
        apointements: @apointements,
        patients: @patients,
        blogs: @blogs
      }
    end

    def update_image_user
      @user = User.find(params[:id])
      if @user.update(params_image_user)
        render json: @user, methods: [:user_image_url, :user_image_url1]
      else
        render json: @user.errors, statut: :unprocessable_entity
      end
    end

    #************************* les fonctions private de classe ***********************#
      private

      def params_image_user
        params.permit(:id, :avatar)
      end

end