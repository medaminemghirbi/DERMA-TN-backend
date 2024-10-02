class Notification < ApplicationRecord
  validates :consultation_id, presence: true
  validates :status, presence: true
  validates :received_at, presence: true
end
