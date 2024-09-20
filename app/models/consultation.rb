class Consultation < ApplicationRecord
  ## Scopes
  enum status: { pending: 0, approved: 1, rejected: 2 }
  scope :current, -> { where(is_archived: false) }

  ## Includes

  ## Callbacks
  before_save :set_start_and_end_time

  ## Validations
  validate :reserved

  ## Associations
  belongs_to :doctor, class_name: 'User', foreign_key: 'doctor_id'
  belongs_to :patient, class_name: 'User', foreign_key: 'patient_id'
  belongs_to :seance

  ## Set start_at and end_at automatically before saving
  def set_start_and_end_time
    return unless seance.present?

    appointment_date = appointment.to_date

    # Combine appointment date with the seance start and end times
    self.start_at = Time.zone.parse("#{appointment_date} #{seance.start_time.strftime('%H:%M')}")
    self.end_at = Time.zone.parse("#{appointment_date} #{seance.end_time.strftime('%H:%M')}")
  end

  private

  def reserved
    if Consultation.where(doctor_id: doctor_id, appointment: appointment, seance: seance).exists?
      errors.add(:base, "The doctor is already booked for this time slot.")
    end
  end

  def self.available_seances_for_date(date, doctor_id)
    # Fetch all Seance records
    all_seances = Seance.all

    # Find consultations for the given date and doctor that are approved
    booked_seances = Consultation.where(appointment: date, doctor_id: doctor_id, status: :approved).pluck(:seance_id)

    # Return seances that are not booked
    all_seances.where.not(id: booked_seances)
  end
end
