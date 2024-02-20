class AddSlugToStreamSlices < ActiveRecord::Migration[7.1]
  def change
    add_column :stream_slices, :slug, :string
    add_index :stream_slices, :slug, unique: true
  end
end
