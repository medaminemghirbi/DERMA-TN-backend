class Api::V1::ConsultationsController < ApplicationController
  before_action :set_consultation, only: [ :update, :destroy]

  # GET /consultations
  def index
    render json: Consultation.current
  end



  # POST /consultations
  def create
    @consultation = Consultation.new(consultation_params)
  
    if check_request_date?
      render json: { error: "You cannot add a request date infeieur at today." }, status: :unprocessable_entity
      return
    end

    if holiday_exists?
      render json: { error: "You cannot add a consultation on a holiday." }, status: :unprocessable_entity
      return
    end

    
    if consultation_with_other_doctor?
      render json: { error: "You already created you cant create  consultation at the same time with a different doctor." }, status: :unprocessable_entity
      return
    end
    if consultation_exists?
      render json: { error: "You already created a consultation request on this date." }, status: :unprocessable_entity
      return
    end

    if @consultation.save
      handle_notifications(@consultation.patient_id, @consultation.doctor_id, @consultation)
      render json: @consultation, status: :created
    else
      render json: @consultation.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /consultations/1
  def update
    @patient = User.find(@consultation.patient_id)

    if valid_status?(consultation_params[:status])
      if @consultation.update(consultation_params)
        handle_notifications(@consultation.patient_id, @consultation.doctor_id, @consultation)
        handle_sms(@consultation.patient_id, @consultation.doctor_id, @consultation)
        render json: @consultation
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
    if @consultation.status == "pending"
      @consultation.update(is_archived: true)
    else
      render json: { error: "You can't delete it." }, status: :unprocessable_entity
    end
  end

  # GET /consultations/doctor_appointments
  def doctor_appointments
    @consultations = Consultation.current.where(doctor_id: params[:doctor_id])
    render json: @consultations, include: {
      doctor: {
        methods: [:user_image_url],
        include: :phone_numbers  # Include phone_numbers here
      },
      patient: { methods: [:user_image_url] }
    }
  end
  def patient_appointments
    @consultations = Consultation.current.where(patient_id: params[:patient_id])
    render json: @consultations, include: {
      doctor: {
        methods: [:user_image_url],
        include: :phone_numbers
      },
      patient: { methods: [:user_image_url] }
    }
  end
  # GET /consultations/doctor_consultations
  def doctor_consultations
    @consultations = Consultation.current.where(doctor_id: params[:doctor_id], status: 1)
    rendered_consultations = @consultations.map do |consultation|
      consultation_hash = consultation.as_json(include: {
        doctor: {
          methods: [:user_image_url],
          include: :phone_numbers
        },
        patient: { methods: [:user_image_url] }
      })

      consultation_hash.merge!(
        appointment: consultation.appointment.in_time_zone('Africa/Tunis').strftime('%Y-%m-%d %H:%M:%S')
      )

      consultation_hash
    end

    render json: rendered_consultations
  end

  # GET /consultations/doctor_consultations_today
  def doctor_consultations_today
    today = Date.current

    @consultations = Consultation.where(
      doctor_id: params[:doctor_id],
      appointment: today.beginning_of_day..today.end_of_day,
      status: 1
    ).sort_by(&:appointment)

    render json: @consultations.as_json(include: {
      patient: { methods: [:user_image_url] }
    }).map do |consultation|
      consultation.merge(
        appointment: consultation['appointment'].strftime('%Y-%m-%d %H:%M:%S')
      )
    end
  end

  # GET /consultations/available_time_slots
  def available_time_slots
    doctor_id = params[:doctor_id]
    date_str = params[:date]
    date = Date.parse(date_str)
    start_of_day = date.beginning_of_day.in_time_zone('Africa/Tunis')
    end_of_day = date.end_of_day.in_time_zone('Africa/Tunis')
  
    approved_consultations = Consultation.where(
      doctor_id: doctor_id,
      status: 1,
      appointment: start_of_day..end_of_day
    )
  
    # Collect occupied slots
    occupied_slots = approved_consultations.pluck(:appointment).map do |appointment|
      appointment.in_time_zone('Africa/Tunis').strftime("%H:%M")
    end
  
    # Prepare available and unavailable slots
    available_slots = TIME_SLOTS.reject { |slot| occupied_slots.include?(slot[:time]) }
    unavailable_slots = TIME_SLOTS.select { |slot| occupied_slots.include?(slot[:time]) }
  
    # Combine available and unavailable slots into a response
    response = {
      available_slots: available_slots,
      unavailable_slots: unavailable_slots
    }
  
    render json: response
  end
  
  def code_room_exist
    consultation = Consultation.find_by(room_code: params[:code])
    if consultation
      render json: consultation, status: :ok
    else
      render json: { error: 'Consultation with the specified room code does not exist.' }, status: :unprocessable_entity
    end
  end

  private

  def check_request_date?
    request_date = params[:appointment]
    if request_date.present? && request_date.to_date < Date.today
      return true
    end
    return false
  end

  def set_consultation
    @consultation = Consultation.find(params[:id])
  end

  def consultation_params
    permitted_params = params.permit(:appointment, :status, :refus_reason, :is_archived, :doctor_id, :patient_id, :appointment_type, :note, :id)
    permitted_params[:appointment_type] = permitted_params[:appointment_type].to_i if permitted_params[:appointment_type].present?
    permitted_params
  end

  def valid_status?(status)
    %w[pending rejected approved canceled].include?(status)
  end

  def holiday_exists?
    Holiday.where(holiday_date: @consultation.appointment).exists?
  end



  def consultation_exists?
    # Check if a consultation already exists for the same patient, doctor, and appointment time
    existing_consultation = Consultation.where(
      appointment: @consultation.appointment,
      doctor_id: @consultation.doctor_id,
      patient_id: @consultation.patient_id
    ).exists?
    existing_consultation
  end

  def consultation_with_other_doctor?
    # Check if the same patient has another consultation at the same time with a different doctor
    overlapping_consultation = Consultation.where(
      appointment: @consultation.appointment,
      patient_id: @consultation.patient_id
    ).where.not(doctor_id: @consultation.doctor_id).exists?
    overlapping_consultation
  end

  def handle_notifications(patient_id, doctor_id, consultation)
    @doctor = User.find(doctor_id)
    @patient = User.find(patient_id)

    if @doctor.is_emailable
      DemandeMailer.send_mail_demande(@doctor, consultation).deliver
    end
    if @patient.is_emailable
      DemandeMailer.send_mail_demande(@patient, consultation).deliver
    end
    if @doctor.is_notifiable
      ActionCable.server.broadcast "ConsultationChannel", {
        consultation: consultation,
        status: consultation.status
      }
    end
    if @patient.is_notifiable
      ActionCable.server.broadcast "ConsultationChannel", {
        consultation: consultation,
        status: consultation.status
      }
    end
  end

  def handle_sms(patient_id, doctor_id, consultation)
    @doctor = User.find(doctor_id)
    @patient = User.find(patient_id)
  
    if @doctor.is_smsable && @patient.is_smsable
      message = "Your request with doctor has been accepted. Check your account."
  
      # Create instances of SmsSender for both the doctor and patient
      sms_sender_to_patient = Twilio::SmsSender.new(body: message, to_phone_number: @patient.phone_number)
  
      begin
        sms_sender_to_patient.send_sms
        sms_sender_to_doctor.send_sms
      rescue => e
        puts "Error sending SMS: #{e.message}"
      end
    end
  end
  
  TIME_SLOTS = [
    { time: "09:00" },
    { time: "09:30" },
    { time: "10:00" },
    { time: "10:30" },
    { time: "11:00" },
    { time: "11:30" },
    { time: "12:00" },
    { time: "13:30" },
    { time: "14:00" },
    { time: "14:30" },
    { time: "15:00" },
    { time: "15:30" },
    { time: "16:00" }
  ]
end
