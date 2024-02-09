class ChannelsController < ApplicationController
  def index
    @channels = Channel.all
  end

  def create
    @channel = Channel.new(params.require(:channel).permit(:name, :thumbnail_image))
    if @channel.save
      redirect_to @channel
    else
      flash[:errors] = @channel.errors.full_messages
      redirect_to new_channel_path
    end
  end

  def edit
  end

  def new
    @channel = Channel.new
  end

  def update
  end

  def show
    @channel = Channel.find(params.require(:id))
  end
end
