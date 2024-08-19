class Maladie < ApplicationRecord
  has_one_attached :image
  validates :maladie_name, presence: true, uniqueness: true
end