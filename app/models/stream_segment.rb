# == Schema Information
#
# Table name: stream_segments
#
#  id               :integer          not null, primary key
#  end_local_usec   :bigint
#  sequence         :integer
#  slug             :string
#  start_local_usec :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  stream_id        :integer
#
# Indexes
#
#  index_stream_segments_on_slug       (slug) UNIQUE
#  index_stream_segments_on_stream_id  (stream_id)
#
class StreamSegment < ApplicationRecord
  include Sluggable

  has_one_attached :source_video

  def duration = (start_local_usec - end_local_usec).to_f / 1_000_000
end
