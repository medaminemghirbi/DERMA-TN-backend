class ConsultationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "ConsultationChannel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
