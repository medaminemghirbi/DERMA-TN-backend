class Consultation < ApplicationRecord
  ##scopes
  enum status: { pending: 0, approved: 1, rejected: 2 }
  scope :current, -> { where(is_archived: false) }
  ##Includes

  ## Callbacks

  ## Validations
  validates :appointment, presence: true
  validates :docteur_id, presence: true
  validates :patient_id, presence: true
  ## Associations
  belongs_to :docteur, class_name: 'User', foreign_key: 'docteur_id'
  belongs_to :patient, class_name: 'User', foreign_key: 'patient_id'
  private
end
