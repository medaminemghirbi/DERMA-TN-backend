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

    if holiday_exists?
      render json: { error: "You cannot add a consultation on a holiday." }, status: :unprocessable_entity
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
      doctor: { methods: [:user_image_url] },
      patient: { methods: [:user_image_url] }
    }
  end

  # GET /consultations/doctor_consultations
  def doctor_consultations
    @consultations = Consultation.current.where(doctor_id: params[:doctor_id], status: 1)
    rendered_consultations = @consultations.map do |consultation|
      consultation_hash = consultation.as_json(include: {
        doctor: { methods: [:user_image_url] },
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

    occupied_slots = approved_consultations.pluck(:appointment).map do |appointment|
      appointment.in_time_zone('Africa/Tunis').strftime("%H:%M")
    end

    available_slots = TIME_SLOTS.reject { |slot| occupied_slots.include?(slot[:time]) }

    render json: available_slots
  end

  private

  def set_consultation
    @consultation = Consultation.find(params[:id])
  end

  def consultation_params
    params.permit(:appointment, :status, :refus_reason, :is_archived, :doctor_id, :patient_id, :id)
  end

  def valid_status?(status)
    %w[pending rejected approved].include?(status)
  end

  def holiday_exists?
    Holiday.where(holiday_date: @consultation.appointment).exists?
  end

  def consultation_exists?
    Consultation.where(
      appointment: @consultation.appointment,
      doctor_id: @consultation.doctor_id,
      patient_id: @consultation.patient_id,
      status: @consultation.status
    ).exists? || 
    Consultation.where(appointment: @consultation.appointment, status: :approved).exists?
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
