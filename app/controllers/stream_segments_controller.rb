class StreamSegmentsController < ApplicationController
  def show
    stream_segment_slug = params.require(:id)
    stream_segment = StreamSegment.find_by!(slug: stream_segment_slug)
    redirect_to stream_segment.source_video
  end

  def update
    stream_slug = params.require(:stream_id)
    stream_segment_slug = params.require(:id)
    stream = Stream.find_by!(slug: stream_slug)
    stream_segment = stream.find_by!(slug: stream_segment_slug)
  end
end
