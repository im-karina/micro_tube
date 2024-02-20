class AddLiveStreamSegmentIdToStreams < ActiveRecord::Migration[7.1]
  def change
    add_reference :streams, :live_stream_slice, foreign_key: { to_table: :stream_slices }
  end
end
