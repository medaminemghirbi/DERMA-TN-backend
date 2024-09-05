class Message < ApplicationRecord
  ##scopes
  scope :current, -> { where(is_archived: false) }
  ##Includes

  ## Callbacks
  after_create_commit { broadcast_message }

  ## Validations

  ## Associations
  belongs_to :sender, class_name: 'User'
  belongs_to :blog
  private
  def broadcast_message
    ActionCable.server.broadcast('MessagesChannel', {
      id: self.id,
      body: self.body,
      sender_id: self.sender_id
    })
  end
end
  
