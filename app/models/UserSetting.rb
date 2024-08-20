class UserSetting < ApplicationRecord
  belongs_to :user
  validates :is_emailable, :is_notifiable, :is_smsable, inclusion: { in: [true, false] }
end
