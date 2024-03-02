class StreamSlicesController < ApplicationController
  include ActiveStorage::SetCurrent

  skip_before_action :verify_authenticity_token
  def create
    stream_id = params.require(:stream_id)
    start_unix_usec = params.require(:start_unix_usec).to_i
    end_unix_usec = params.require(:end_unix_usec).to_i

    stream = Stream.find_by(slug: stream_id)
    start_local_usec = start_unix_usec - stream.start_unix_usec
    end_local_usec = end_unix_usec - stream.start_unix_usec

    @stream_slice = StreamSlice.create!(stream:, start_local_usec:, end_local_usec:, finalized_at: Time.zone.now)
    @segments = @stream_slice.stream_segments

    respond_to do |format|
      format.json { render json: { stream_slice: { stream_id: stream.slug, id: @stream_slice.slug } } }
      format.html
      format.m3u8
    end
  end

  def show
    @stream_slice = StreamSlice.find_by!(slug: params.require(:id))
    @segments = @stream_slice.stream_segments
    @sequence_start = @segments.map(&:sequence).min

    respond_to do |format|
      format.json
      format.html
      format.m3u8
    end
  end
end
