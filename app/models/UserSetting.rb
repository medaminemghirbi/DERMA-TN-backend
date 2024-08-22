class UserSetting < ApplicationRecord
  self.table_name = "user_settings"
  ##scopes
    scope :current, -> { where(is_archived: false) }
  ##Includes

  ## Callbacks

  ## Validations
  validates :is_emailable, :is_notifiable, :is_smsable, inclusion: { in: [true, false] }

  ## Associations
  belongs_to :user # No need to specify class_name or foreign_key since STI handles this

  private

end
