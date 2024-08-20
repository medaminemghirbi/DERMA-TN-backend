class ConsultationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "consultation_#{params[:consultation_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
