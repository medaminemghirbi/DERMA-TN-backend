class Blog < ApplicationRecord
  belongs_to :doctor # Assuming only doctors can create blogs
  has_many_attached :images

  validates :title, presence: true
  validates :content, presence: true
  validates :images, presence: true, if: -> { images.attached? }

end
