class Consultation < ApplicationRecord
  belongs_to :docteur, class_name: 'User', foreign_key: 'docteur_id'
  belongs_to :patient, class_name: 'User', foreign_key: 'patient_id'

  enum status: { pending: 0, approved: 1, rejected: 2 }

  validates :appointment, presence: true
  validates :docteur_id, presence: true
  validates :patient_id, presence: true

  # Add any additional custom validations, scopes, or methods if necessary
end