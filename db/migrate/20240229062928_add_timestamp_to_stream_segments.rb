class AddTimestampToStreamSegments < ActiveRecord::Migration[7.1]
  def change
    add_column :stream_segments, :unix_ms_timestamp, :bigint
  end
end
