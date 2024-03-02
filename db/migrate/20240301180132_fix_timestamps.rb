class FixTimestamps < ActiveRecord::Migration[7.1]
  def change
    add_column :streams, :start_unix_usec, :bigint
    add_column :stream_slices, :start_local_usec, :bigint
    add_column :stream_slices, :end_local_usec, :bigint
    add_column :stream_segments, :start_local_usec, :bigint
    add_column :stream_segments, :end_local_usec, :bigint

    remove_column :stream_slices, :start_time
    remove_column :stream_slices, :start_timestamp
    remove_column :stream_slices, :end_time
    remove_column :stream_slices, :end_timestamp

    remove_column :stream_segments, :duration
    remove_column :stream_segments, :offset
    remove_column :stream_segments, :unix_ms_timestamp

  end
end
