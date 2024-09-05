class Api::V1::ConsultationSerializer < ActiveModel::Serializer
  attributes :id, :appointment, :status, :is_archived, :doctor_id, :patient_id, :refus_reason, :created_at, :updated_at

  belongs_to :doctor, serializer: Api::V1::DoctorSerializer
  belongs_to :patient, serializer: Api::V1::PatientSerializer

  def appointment
    appointment = object.appointment # Ensure this is a DateTime or Time object
    appointment.strftime("%A, %d of %B %Y at %H:%M") if appointment
  end

  def created_at
    created_at = object.created_at # Ensure this is a DateTime or Time object
    created_at.strftime("%A, %d of %B %Y at %H:%M") if created_at
  end
end
