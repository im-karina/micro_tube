class StreamsController < ApplicationController
  def index
    @streams = Stream.all
  end

  def show
    @stream = Stream.find_by(slug: params.require(:id))
  end

  def new
    @stream = Stream.new
  end

  def create
    @stream = Stream.create!
    redirect_to @stream
  end
end
