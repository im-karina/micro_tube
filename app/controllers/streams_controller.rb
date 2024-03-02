class StreamsController < ApplicationController
  skip_forgery_protection
  #skip_before_action :authenticate_user!

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
    start_unix_usec = params.require(:start_unix_usec)
    @stream = Stream.create!(start_unix_usec:)
    respond_to do |fmt|
      fmt.html do 
        redirect_to @stream
      end
      fmt.json do
        segments = @stream.stream_segments
        render json: { stream: { id: @stream.slug, segments: } }
      end
    end
  end

  def update
    stream = Stream.find_by!(slug: params.require(:id))
    segments = params.require(:stream).fetch(:stream_segments)

    segments = segments.map do |segment_params|
      duration = segment_params.require(:duration).to_i
      source_video = segment_params.require(:source_video)
      start_unix_usec = segment_params.require(:start_unix_usec).to_i
      end_unix_usec = start_unix_usec + duration * 1_000_000
      sequence = segment_params.require(:sequence)

      start_local_usec = start_unix_usec - stream.start_unix_usec
      end_local_usec = end_unix_usec - stream.start_unix_usec

      stream.stream_segments.create!(
        source_video:,
        sequence:,
        start_local_usec:,
        end_local_usec:,
      )
    end

    render json: { stream: { segments: } }
  end
end
