
class Api::Mobile::ConsultationsController < ApplicationController
  before_action :authorize_request
  def patient_consultations_today
    today = Date.current

    @consultations = Consultation.where(
      patient_id: params[:patient_id],
      appointment: today.beginning_of_day..today.end_of_day,
      status: 1
    ).sort_by(&:appointment)

    render json: @consultations.as_json(include: {
      doctor: {methods: [:user_image_url]}
    }).map do |consultation|
      consultation.merge(
        appointment: consultation["appointment"].strftime("%Y-%m-%d %H:%M:%S")
      )
    end
  end
end