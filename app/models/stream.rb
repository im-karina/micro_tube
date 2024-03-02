# == Schema Information
#
# Table name: streams
#
#  id                   :integer          not null, primary key
#  slug                 :string           not null
#  start_unix_usec      :bigint
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  live_stream_slice_id :integer
#
# Indexes
#
#  index_streams_on_live_stream_slice_id  (live_stream_slice_id)
#  index_streams_on_slug                  (slug) UNIQUE
#
# Foreign Keys
#
#  live_stream_slice_id  (live_stream_slice_id => stream_slices.id)
#
class Stream < ApplicationRecord
  include Sluggable

  before_validation { self.live_stream_slice ||= StreamSlice.new(stream: self) }

  has_many :stream_segments

  belongs_to :live_stream_slice, class_name: 'StreamSlice'

  validates :start_unix_usec, presence: true
end
