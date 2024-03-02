class AddFinalizedAtToStreamSegments < ActiveRecord::Migration[7.1]
  def change
    add_column :stream_slices, :finalized_at, :datetime
  end
end
