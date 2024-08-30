class Api::V1::MessagesController < ApplicationController
  before_action :set_user, only: %i[ create index]
  def index
    @messages = Message.order(created_at: :asc)
    render json: @messages.as_json(include: :sender)
  end
  # POST /messages
  def create
    @message = Message.new(message_params)
    @message.sender_id = @user.id
    if @message.save
      ActionCable.server.broadcast 'MessagesChannel', @message.as_json(include: :sender)
      render json: @message, status: :created
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end


  # DELETE /messages/1
  def destroy
    @message.destroy
  end

  private
    def set_user
      @user = User.find(params[:sender_id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:body, :sender_id)
    end
end
