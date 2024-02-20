# == Schema Information
#
# Table name: stream_slices
#
#  id         :integer          not null, primary key
#  end_time   :decimal(, )
#  slug       :string
#  start_time :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  stream_id  :integer
#
# Indexes
#
#  index_stream_slices_on_slug       (slug) UNIQUE
#  index_stream_slices_on_stream_id  (stream_id)
#
class StreamSlice < ApplicationRecord
  include Sluggable

  belongs_to :stream

  def segments
    stream.stream_segments
  end
end
