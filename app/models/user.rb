class User < ApplicationRecord
  self.table_name = "users"

  ##scopes
  scope :current, -> { where(is_archived: false) }

  ##Includes
  include Rails.application.routes.url_helpers

  ## Callbacks
  after_create :create_user_settings_for_patient
  before_create :confirmation_token

  ## Validations
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :lastname, presence: true
  validates :firstname, presence: true

  ## Associations
  has_one_attached :avatar, dependent: :destroy
  has_many :sent_messages, class_name: 'Message'
  has_many :received_messages, class_name: 'Message'
  has_one :user_setting, dependent: :destroy
  def user_image_url
    # Get the URL of the associated image
    avatar.attached? ? url_for(avatar) : nil
  end
  private

  def create_user_settings_for_patient
    create_user_setting! unless self.type != 'Patient'
  end

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
  end

  def confirmation_token
    self.confirm_token = SecureRandom.urlsafe_base64.to_s if confirm_token.blank?
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.forgot_password(self).deliver # This sends an e-mail with a link for the user to reset the password
  end

  # This generates a random password reset token for the user
  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end


end
