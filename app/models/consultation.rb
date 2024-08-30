class Consultation < ApplicationRecord
  ##scopes
  enum status: { pending: 0, approved: 1, rejected: 2 }
  scope :current, -> { where(is_archived: false) }
  ##Includes

  ## Callbacks

  ## Validations
  validates :appointment, presence: true
  validates :doctor_id, presence: true
  validates :patient_id, presence: true
  ## Associations
  belongs_to :doctor, class_name: 'User', foreign_key: 'doctor_id'
  belongs_to :patient, class_name: 'User', foreign_key: 'patient_id'

  def formatted_appointment
    appointment = self[:appointment].is_a?(String) ? DateTime.parse(self[:appointment]) : self[:appointment]
    appointment.strftime("%A, %d of %B %Y at %H:%M")

  end
end
