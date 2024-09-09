class Consultation < ApplicationRecord
  ##scopes
  enum status: { pending: 0, approved: 1, rejected: 2 }
  scope :current, -> { where(is_archived: false) }
  enum seance: {
    "09:00": 1,
    "09:30": 2,
    "10:00": 3,
    "10:30": 4,
    "11:00": 5,
    "11:30": 6,
    "12:00": 7,
    "12:30": 8,
    "13:00": 9,
    "13:30": 10,
    "14:00": 11,
    "14:30": 12,
    "15:00": 13,
    "15:30": 14,
    "16:00": 15,
    "16:30": 16
  }
  ##Includes

  ## Callbacks

  ## Validations

  ## Associations
  belongs_to :doctor, class_name: 'User', foreign_key: 'doctor_id'
  belongs_to :patient, class_name: 'User', foreign_key: 'patient_id'

  def reserved
    if Consultation.where(doctor_id: doctor_id, appointment: appointment, seance: seance).exists?
      errors.add(:base, "The doctor is already booked for this time slot.")
    end
  end
end
