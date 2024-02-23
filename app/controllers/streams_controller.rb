class StreamsController < ApplicationController
  skip_forgery_protection
  skip_before_action :authenticate_user!

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

  def update
    stream = Stream.find_by!(slug: params.require(:id))
    segments = params.require(:stream).fetch(:stream_segments)

    segments = segments.map do |segment_params|
      binding.pry
      offset = segment_params.require(:offset)
      duration = segment_params.require(:duration)
      source_video = segment_params.require(:source_video)

      stream.stream_segments.create!(
        duration:,
        offset:,
        source_video:,
      )
    end

    render json: { stream: { segments: } }
  end
end
