class Api::V1::Web::ConsultationsController < ApplicationController
  before_action :set_consultation, only: [:show, :update, :destroy]
  before_action :authorize_request
  # GET /consultations
  def index
    render json: Consultation.current
  end

  # GET /consultations/1
  def show
    render json: @consultation
  end

  # POST /consultations
  def create
    @consultation = Consultation.new(consultation_params)  
    # Check if start_date or end_date falls within a holiday
    if Holiday.where(holiday_date: @consultation.appointment).exists?
      render json: { error: "You cannot add a leave request on a holiday." }, status: :unprocessable_entity
      return
    end
  
    if @consultation.save
      DemandeMailer.send_mail_demande(@consultation.user, @consultation).deliver
      render json: @consultation, status: :created
    else
      render json: @consultation.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /consultations/1
  def update
    @consultation = Consultation.find(params[:id])
    
    if ["pending", "rejected"].include?(consultation_params[:status])
      @consultation.update(consultation_params)
      DemandeMailer.send_mail_demande(@consultation.user, @consultation).deliver
      render json: @consultation, include: [:user]
    elsif consultation_params[:status] == "approved"
      @user = User.find(@consultation.user_id)
      if @user
        DemandeMailer.send_mail_demande(@consultation.user, @consultation).deliver
        if @user.mobile.present?
          to_phone_number = "+216#{@user.mobile}"
          body = "Your consultation has been approved. Please check your phone for details."
          sms_service = Twilio::SmsService.new(
            body: body,
            to_phone_number: to_phone_number
          )
          sms_service.call
        else
          Rails.logger.warn("User #{@user.id} has no mobile number.")
        end
        render json: @demande, include: [:user, :type_conge]
      else
        render json: { error: 'User not found' }, status: :not_found
      end
    else
      render json: @demande.errors, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error("Failed to update request: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end
  # DELETE /consultations/1
  def destroy
    if(@consultation[:status] =="pending")
      @consultation.update(is_archived: true)
    else
      render json: { error: "You Can't delete it." }, status: :unprocessable_entity
      return
    end
  end

  #render consultations by Patients
  def patient_consultations
    @consultations = Consultation.current.where(user_id: params[:user_id]).includes(:user).all
    render json: @consultations, include: {
      user: { only: [:id, :email, :lastname, :firstname] }
    }
  end


  private
    def set_consultation
      @consultation = Consultation.find(params[:id])
    end

    def consultation_params
      params.permit(:appointment, :status, :refus_reason, :is_archived, :user_id, :id)
    end  
end