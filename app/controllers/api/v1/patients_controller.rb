class Api::V1::PatientsController < ApplicationController
  before_action :set_patient, only: [:destroy]
  before_action :authorize_request
    def  index
      render json: Patient.current.all
    end

  def destroy
    @Patient = Patient.find(params[:id])
    @Patient.update(is_archived: true)
  end


  #************************* les fonctions private de classe ***********************#

  private

  def set_patient
    @Patient = Patient.find(params[:id])
  end

end
