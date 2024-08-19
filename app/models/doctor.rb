class Doctor < User
  include Rails.application.routes.url_helpers
  has_one_attached :avatar
  geocoded_by :address
  after_validation :geocode, if: ->(obj){ obj.address.present? and obj.address_changed? }
  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode

  def user_image_url
    # Get the URL of the associated image
    avatar.attached? ? url_for(avatar) : nil
  end

end
