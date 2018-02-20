class MessagesController < ApplicationController
  
  def create
    @message = Message.new(message_params)
    @message.chef = current_chef
    if @message.save
      redirect_to chat_path
    else
      render 'chatrooms/show'
    end
  end
  
  private
  
  def message_params
    params.require(:message).permit(:content)
  end
end