class Api::V1::CustomMailsController < ApplicationController
  def get_all_emails_doctor
    if params[:type] == 'Doctor'
      emails = CustomMail.where(doctor_id: params[:id]).order(:sent_at)
    elsif params[:type] == 'Patient'
      emails = CustomMail.where(patient_id: params[:id]).order(:sent_at)
    else
      render json: { error: 'Invalid type parameter. Must be "doctor" or "patient".' }, status: :unprocessable_entity
      return
    end
  
    render json: emails
  end
  
  def destroy
    @message = CustomMail.find(params[:id])
    @message.destroy
  end
end