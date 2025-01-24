class Blog < ApplicationRecord
  ##scopes
  scope :current, -> { where(is_archived: false) }
  scope :verified, -> { where(is_verified: true) }

  ##Includes
  include Rails.application.routes.url_helpers

  ## Callbacks

  ## Validations
  validates :title, presence: true
  validates :content, presence: true
  validates :images, presence: true, if: -> { images.attached? }


  ## Associations
  has_many :messages, dependent: :destroy
  belongs_to :doctor, class_name: 'User'
  belongs_to :maladie
  has_many :reactions, dependent: :destroy
  has_many_attached :images

  has_many :blog_reactions
  has_many :reacting_users, through: :blog_reactions, source: :user

  def image_urls
    images.map { |image|  url_for(image) }
  end

  def likes_count
    blog_reactions.where(reaction: 'like').count
  end

  # Returns the count of dislikes
  def dislikes_count
    blog_reactions.where(reaction: 'dislike').count
  end

end
