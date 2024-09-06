class Message < ApplicationRecord
  scope :current, -> { where(is_archived: false) }
  after_create_commit { broadcast_message }
  belongs_to :sender, class_name: 'User'
  private

  def broadcast_message
    ActionCable.server.broadcast('MessagesChannel', {
      id: self.id,
      body: self.body,
      sender_id: self.sender_id,
      sender: {
        user_image_url: self.sender.user_image_url,
        firstname: self.sender.firstname,
        lastname: self.sender.lastname
      },
      created_at: self.created_at.strftime('%Y-%m-%d %H:%M:%S') # Adjust format if needed
    })
  end
end