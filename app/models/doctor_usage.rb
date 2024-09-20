# app/models/doctor_usage.rb
class DoctorUsage < ApplicationRecord
  belongs_to :doctor

  validates :date, uniqueness: { scope: :doctor_id }

  # Track daily usage
  def self.track_usage(doctor)
    usage = find_or_create_by(doctor: doctor, date: Date.today)
    usage.increment!(:count)
  end

  def self.usage_limit_reached?(doctor, limit)
    usage = find_or_create_by(doctor: doctor, date: Date.today)
    usage.count >= limit
  end
end
