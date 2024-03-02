class AddStartTimestampEndTimestampToStreamSlices < ActiveRecord::Migration[7.1]
  def change
    add_column :stream_slices, :start_timestamp, :datetime
    add_column :stream_slices, :end_timestamp, :datetime
  end
end
