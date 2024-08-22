class Maladie < ApplicationRecord
  ##scopes
  scope :current, -> { where(is_archived: false) }
  ##Includes

  ## Callbacks

  ## Validations
  validates :maladie_name, presence: true, uniqueness: true

  ## Associations
  has_one_attached :image

  private

end