class Notification < ApplicationRecord
  validates :status, presence: true
  validates :received_at, presence: true
end
