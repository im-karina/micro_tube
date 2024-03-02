class AddSequenceToStreamSegments < ActiveRecord::Migration[7.1]
  def change
    add_column :stream_segments, :sequence, :integer
  end
end
