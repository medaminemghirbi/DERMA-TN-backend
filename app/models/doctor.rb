class Doctor < User
  ##scopes
  scope :current, -> { where(is_archived: false) }
  ##Includes
  include Rails.application.routes.url_helpers
  enum plan: { no_plan: 0 ,basic: 1, premium: 2, custom: 3 }

  has_one_attached :avatar
  has_one :doctor_usage

  geocoded_by :address
  ## Callbacks

  ## Validations
  after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? }
  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode

  ## Associations
  has_one_attached :avatar
  has_many :blogs, dependent: :destroy
  has_many :consultations, dependent: :destroy
  has_many :phone_numbers, dependent: :destroy


  def daily_limit
    case plan
    when 'no_plan'
      0
    when 'basic'
      3
    when 'premium'
      Float::INFINITY
    when 'custom'
      self.custom_limit
    else
      0
    end
  end
  def user_image_url
    # Get the URL of the associated image
    avatar.attached? ? url_for(avatar) : nil
  end
end