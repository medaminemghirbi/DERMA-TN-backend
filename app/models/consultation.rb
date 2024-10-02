class Consultation < ApplicationRecord
  ## Scopes
  enum status: { pending: 0, approved: 1, rejected: 2 }
  scope :current, -> { where(is_archived: false) }
  after_create_commit { broadcast_notification }

  ## Includes

  ## Callbacks

  ## Validations
  validates :appointment, presence: true
  validate :verified_consultation_booked, on: :create

  ## Associations
  belongs_to :doctor, class_name: 'User', foreign_key: 'doctor_id'
  belongs_to :patient, class_name: 'User', foreign_key: 'patient_id'


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

  private
  def verified_consultation_booked
    if Consultation.where(appointment: appointment, status: :approved, doctor_id: doctor_id).exists?
      errors.add(:appointment, "is already booked for an approved consultation at this time.")
    end
  end


  def broadcast_notification
    ActionCable.server.broadcast('ConsultationChannel', {
      id: self.id,
      appointment: self.appointment,
      status: self.status,
      doctor_id: self.doctor_id,
      patient_id: self.patient_id,
      refus_reason: self.refus_reason,

    })
  end
end
