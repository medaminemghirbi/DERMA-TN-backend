class Api::V1::CustomMailsController < ApplicationController
  def get_all_emails_doctor
    render json: CustomMail.where(doctor_id: params[:id]).order(:sent_at)
  end
  def destroy
    @message = CustomMail.find(params[:id])
    @message.destroy
  end
end