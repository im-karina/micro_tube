# == Schema Information
#
# Table name: stream_slices
#
#  id               :integer          not null, primary key
#  end_local_usec   :bigint
#  finalized_at     :datetime
#  slug             :string
#  start_local_usec :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  stream_id        :integer
#
# Indexes
#
#  index_stream_slices_on_slug       (slug) UNIQUE
#  index_stream_slices_on_stream_id  (stream_id)
#
class StreamSlice < ApplicationRecord
  include Sluggable

  belongs_to :stream

  def stream_segments
    relation = stream.stream_segments.order(sequence: :asc)

    relation = relation.where('end_local_usec > ?', start_local_usec) if start_local_usec
    relation = relation.where('start_local_usec < ?', end_local_usec) if end_local_usec
    relation = relation.last(12) unless finalized?

    relation
  end

  def finalized? = !!finalized_at
end
