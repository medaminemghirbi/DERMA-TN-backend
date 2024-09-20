class Api::V1::ConsultationsController < ApplicationController
  before_action :set_consultation, only: [:show, :update, :destroy]
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
    if Holiday.where(holiday_date: @consultation.appointment).exists?
      render json: { error: "You cannot add a consultation on a holiday." }, status: :unprocessable_entity
      return
    end
    if Consultation.where(appointment: @consultation.appointment, seance: @consultation.seance).where(status: :approved).exists?
      render json: { error: "date not available" }, status: :unprocessable_entity
      return
    end
    if Consultation.where(
        appointment: @consultation.appointment,
        seance: @consultation.seance,
        doctor_id: @consultation.doctor_id,
        patient_id: @consultation.patient_id,
        status: @consultation.status
      ).exists?
      render json: { error: "you already created a consultation demande on this date" }, status: :unprocessable_entity
      return
    end
    if @consultation.save
      #DemandeMailer.send_mail_demande(@consultation.user, @consultation).deliver
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

  # render consultations by Doctors
  def doctor_consultations
    @consultations = Consultation.current.where(doctor_id: params[:doctor_id])
    render json: @consultations, 
      include: {
        doctor: { methods: [:user_image_url] },
        patient: { methods: [:user_image_url] }
      }
  end

  
  def doctor_consultations_today
    today = Date.current
  
    @consultations = Consultation.current
                                  .where(doctor_id: params[:doctor_id], appointment: today)
    
    # Sort the consultations in Ruby
    @consultations = @consultations.sort_by do |consultation|
      seance = consultation.seance
      # Convert seance to a sortable format
      if seance.include?(":")
        # Handle time format "HH:MM"
        hours, minutes = seance.split(":").map(&:to_i)
        hours * 60 + minutes
      else
        # Handle numeric format
        seance.to_i * 60
      end
    end
  
    render json: @consultations, 
      include: {
        patient: { methods: [:user_image_url] }
      }
  end
  
  def available_seances
    date = params[:date]
    doctor_id = params[:doctor_id]

    # Ensure both parameters are provided
    if date.present? && doctor_id.present?
      available_seances = Consultation.available_seances_for_date(date, doctor_id)

      render json: {
        available_seances: available_seances.map do |seance|
          {
            id: seance.id,
            start_time: seance.start_time.strftime('%H:%M'), # Format start_at as HH:MM
            end_time: seance.end_time.strftime('%H:%M')    # Format end_at as HH:MM
          }
        end
      }
    else
      render json: { status: 'error', message: 'Date and doctor_id are required' }, status: :bad_request
    end
  end


  private
    def set_consultation
      @consultation = Consultation.find(params[:id])
    end

    def consultation_params
      params.permit(:appointment, :status, :refus_reason, :is_archived, :doctor_id, :patient_id, :seance)
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