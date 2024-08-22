class Blog < ApplicationRecord
  ##scopes
  scope :current, -> { where(is_archived: false) }
  ##Includes

  ## Callbacks

  ## Validations
  validates :title, presence: true
  validates :content, presence: true
  validates :images, presence: true, if: -> { images.attached? }

  ## Associations
  belongs_to :doctor # Assuming only doctors can create blogs
  has_many_attached :images
  private
end
