class User < ApplicationRecord
  self.table_name = "users"
  enum gender: [:male, :female]
  enum civil_status: [:Mr, :Mrs, :Mme, :other]
  # encrypts :email, deterministic: true
  # #scopes
  scope :current, -> { where(is_archived: false) }

  # #Includes
  include Rails.application.routes.url_helpers

  ## Callbacks
  before_create :confirmation_token
  before_save :generate_code_doc
  before_create :attach_avatar_based_on_gender

  ## Validations
  has_secure_password
  validates :email, presence: true, uniqueness: true
  validates :lastname, presence: true
  validates :firstname, presence: true

  ## Associations
  has_one_attached :avatar, dependent: :destroy

  has_many :phone_numbers, dependent: :destroy
  has_many :sent_messages, class_name: "Message"
  has_many :received_messages, class_name: "Message"

  has_many :blog_reactions
  has_many :reacted_blogs, through: :blog_reactions, source: :blog

  def user_image_url
    # Get the URL of the associated image
    avatar.attached? ? url_for(avatar) : nil
  end

  def user_image_url_mobile
    # Get the URL of the associated image
    image_url = Rails.application.routes.url_helpers.rails_blob_url(avatar, only_path: false)
    host = AppConfig.find_by(key: "mobile")&.value || "localhost:3000"
    image_url.gsub("localhost:3000", host)
  end

  def validate_confirmation_code(code)
    if confirmation_code == code
      update(email_confirmed: true, confirmation_code: nil, confirmation_code_generated_at: nil)
      true
    else
      false
    end
  end

  def confirmation_code_expired?
    confirmation_code_generated_at.nil? || (Time.current > (confirmation_code_generated_at + 5.minute))
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.forgot_password(self).deliver # This sends an e-mail with a link for the user to reset the password
  end

  private

  def attach_avatar_based_on_gender
    if male?
      avatar.attach(io: File.open(Rails.root.join("app", "assets", "images", "default_avatar.png")), filename: "default_avatar.png", content_type: "image/png")
    else
      avatar.attach(io: File.open(Rails.root.join("app", "assets", "images", "default_female_avatar.png")), filename: "default_female_avatar.png", content_type: "image/png")
    end
  end

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
  end

  def confirmation_token
    self.confirm_token = SecureRandom.urlsafe_base64.to_s if confirm_token.blank?
  end

  # This generates a random password reset token for the user
  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless User.exists?(column => self[column])
    end
  end

  def generate_code_doc
    current_year = Time.now.year
    # Get the first two characters of the first and last name
    first_two_firstname = firstname[0, 2].capitalize
    first_two_lastname = lastname[0, 2].capitalize

    # Generate the new code
    self.code_doc = "Dr-#{first_two_firstname}-#{first_two_lastname}-#{current_year}"
  end
end
