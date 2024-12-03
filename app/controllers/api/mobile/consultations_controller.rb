
class Api::Mobile::ConsultationsController < ApplicationController
  before_action :authorize_request
  before_action :set_consultation, only: [:destroy]
  def patient_consultations_today
    today = Date.current

    @consultations = Consultation.where(
      patient_id: params[:patient_id],
      appointment: today.beginning_of_day..today.end_of_day,
      status: 1
    ).sort_by(&:appointment)

    render json: @consultations.as_json(include: {
      doctor: {
        methods: [:user_image_url_mobile],
        include: {
          phone_numbers: { only: [:number] } # Include the phone number data
        }
      }
    }).map do |consultation|
      consultation.merge(
        appointment: consultation["appointment"].strftime("%Y-%m-%d %H:%M:%S")
      )
    end
  end

  def patient_appointments
    page = params[:page] || 1
    per_page = params[:per_page] || 10
    @consultations = Consultation.current
                                .where(patient_id: params[:patient_id])
                                .page(page)
                                .per(per_page)
                                .order(appointment: :asc)
    render json: @consultations, include: {
      doctor: {
        only: [:firstname, :lastname, :address,:latitude,:longitude], methods: [:first_number, :user_image_url_mobile]
      },
      patient: { only: [:firstname, :lastname] }
    }
  end

  def destroy
    if @consultation.status == "pending"
      if @consultation.update(is_archived: true)
        render json: { message: "Consultation Deleted successfully." }, status: 200
      else
        render json: { error: "Failed to archive consultation." }, status: :unprocessable_entity
      end
    else
      render json: { error: "You can't delete this consultation." }, status: :unprocessable_entity
    end
  end
  

  private
  def set_consultation
    @consultation = Consultation.find(params[:id])
  end

end