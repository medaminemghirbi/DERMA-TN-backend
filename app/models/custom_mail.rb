class CustomMail < ApplicationRecord
  belongs_to :doctor
  belongs_to :patient

  validates :body, presence: true
  after_create_commit { broadcast_notification }

  private
  def broadcast_notification
    ActionCable.server.broadcast('MailChannel', {
      id: self.id,
      subject: self.subject,
      body: self.body,
      sent_at: self.sent_at
    })
  end
end
