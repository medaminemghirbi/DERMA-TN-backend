class Patient < User
  scope :current, -> { where(is_archived: false) }
  ##Includes
  include Rails.application.routes.url_helpers

  has_one_attached :avatar  ##Includes

  ## Callbacks

  ## Validations

  ## Associations

  def user_image_url
    # Get the URL of the associated image
    avatar.attached? ? url_for(avatar) : nil
  end
end
