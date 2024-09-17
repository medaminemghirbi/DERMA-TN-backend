class Consultation < ApplicationRecord
  ##scopes
  enum status: { pending: 0, approved: 1, rejected: 2 }
  scope :current, -> { where(is_archived: false) }
  NORMAL_SEANCE_TIMES = {
    1 => ["09:00", "09:30"],
    2 => ["09:30", "10:00"],
    3 => ["10:00", "10:30"],
    4 => ["10:30", "11:00"],
    5 => ["11:00", "11:30"],
    6 => ["11:30", "12:00"],
    7 => ["12:00", "12:30"],
    8 => ["13:30", "14:00"],
    9 => ["14:00", "14:30"],
    10 => ["14:30", "15:00"],
    11 => ["15:00", "15:30"],
    12 => ["15:30", "16:00"],
    13 => ["16:00", "16:30"],
    14 => ["16:30", "17:00"]
  }
  RAMADAN_SEANCE_TIMES = {
    1 => ["09:00", "09:30"],
    2 => ["09:30", "10:00"],
    3 => ["10:00", "10:30"],
    4 => ["10:30", "11:00"],
    5 => ["11:00", "11:30"],
    6 => ["11:30", "12:00"],
    7 => ["12:00", "12:30"],
    8 => ["12:30", "13:00"],
    9 => ["13:00", "13:30"],
    10 => ["13:30", "14:00"]
  }
  ETE_SEANCE_TIMES = {
    1 => ["08:00", "08:30"],
    2 => ["08:30", "09:00"],
    3 => ["09:00", "09:30"],
    4 => ["09:30", "10:00"],
    5 => ["10:00", "10:30"],
    6 => ["10:30", "11:00"],
    7 => ["11:00", "11:30"],
    8 => ["11:30", "12:00"],
    9 => ["12:00", "12:30"],
    10 => ["12:30", "13:00"],
    11 => ["13:00", "13:30"],
    12 => ["13:30", "14:00"],
    13 => ["14:00", "14:30"]

  }

  FRIDAY_TIME = {
    1 => ["08:00", "08:30"],
    2 => ["08:30", "09:00"],
    3 => ["09:00", "09:30"],
    4 => ["09:30", "10:00"],
    5 => ["10:00", "10:30"],
    6 => ["10:30", "11:00"],
    7 => ["11:00", "11:30"],
    8 => ["11:30", "12:00"],
    9 => ["12:00", "12:30"],
    10 => ["12:30", "13:00"],
    11 => ["13:00", "13:30"]
  }
  ##Includes

  ## Callbacks
  before_save :set_start_and_end_time


  ## Validations
  validate :reserved

  ## Associations
  belongs_to :doctor, class_name: 'User', foreign_key: 'doctor_id'
  belongs_to :patient, class_name: 'User', foreign_key: 'patient_id'

    ## Set start_at and end_at automatically before saving
    def set_start_and_end_time
      return unless seance.present?
  
      start_time_str, end_time_str = NORMAL_SEANCE_TIMES[seance_before_type_cast]
      appointment_date = appointment.to_date
  
      # Combine date with start and end time strings
      self.start_at = Time.zone.parse("#{appointment_date} #{start_time_str}")
      self.end_at = Time.zone.parse("#{appointment_date} #{end_time_str}")
    end
  private
  def reserved
    if Consultation.where(doctor_id: doctor_id, appointment: appointment, seance: seance).exists?
      errors.add(:base, "The doctor is already booked for this time slot.")
    end
  end

end
