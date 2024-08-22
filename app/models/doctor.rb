class Doctor < User
  ##scopes
  scope :current, -> { where(is_archived: false) }
  ##Includes
  include Rails.application.routes.url_helpers

  has_one_attached :avatar
  geocoded_by :address
  ## Callbacks

  ## Validations
  validates :maladie_name, presence: true, uniqueness: true
  after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? }
  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode

  ## Associations
  has_one_attached :avatar
  has_many :blogs, dependent: :destroy

  private
  def user_image_url
    # Get the URL of the associated image
    avatar.attached? ? url_for(avatar) : nil
  end
end