class CustomMail < ApplicationRecord
  belongs_to :doctor
  belongs_to :patient

  validates :body, presence: true
end
