class Api::V1::ConsultationsController < ApplicationController
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
      render json: { error: "You cannot add a consultation on a holiday." }, status: :unprocessable_entity
      return
    end
  
    if @consultation.save
      DemandeMailer.send_mail_demande(@consultation.user, @consultation).deliver
      render json: @consultation, status: :created
    else
      render json: @consultation.errors, status: :unprocessable_entity
    end
  end

  def update
    @consultation = Consultation.find(params[:id])
    @patient = User.find(@consultation.patient_id)
    
    if valid_status?(consultation_params[:status])
      if @consultation.update(consultation_params)
        handle_notifications(@patient, @consultation)
        render json: @consultation, include: [:user]
      else
        render json: @consultation.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid status' }, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error("Failed to update consultation: #{e.message}")
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

  #render consultations by Doctors
  def doctor_consultations
    @consultations = Consultation.current.where(docotor_id: params[:docotor_id]).all
    render json: @consultations
  end




  private
    def set_consultation
      @consultation = Consultation.find(params[:id])
    end

    def consultation_params
      params.permit(:appointment, :status, :refus_reason, :is_archived, :user_id, :id)
    end  


    def valid_status?(status)
      ["pending", "rejected", "approved"].include?(status)
    end
    
    def handle_notifications(patient, consultation)
      if patient.user_setting.is_emailable
        DemandeMailer.send_mail_demande(patient, consultation).deliver
      end
    
      if patient.user_setting.is_smsable && patient.mobile.present?
        to_phone_number = "+216#{patient.mobile}"
        body = "Your consultation status has been updated."
        sms_service = Twilio::SmsService.new(
          body: body,
          to_phone_number: to_phone_number
        )
        sms_service.call
      end
    
      if patient.user_setting.is_notifiable
        ActionCable.server.broadcast "consultation_#{consultation.id}", {
          consultation: consultation,
          status: consultation.status
        }
      end
    end
end