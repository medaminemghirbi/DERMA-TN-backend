class Message < ApplicationRecord
  ##scopes
  scope :current, -> { where(is_archived: false) }
  ##Includes

  ## Callbacks
  after_create_commit { broadcast_message }

  ## Validations

  ## Associations
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  private
  def broadcast_message
    ActionCable.server.broadcast('MessagesChannel', {
      id: self.id,
      body: self.body
    })
  end
end
  