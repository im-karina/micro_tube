class AddSlugToStreamSegments < ActiveRecord::Migration[7.1]
  def change
    add_column :stream_segments, :slug, :string
    add_index :stream_segments, :slug, unique: true
  end
end
