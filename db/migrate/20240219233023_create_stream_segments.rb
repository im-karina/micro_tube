class CreateStreamSegments < ActiveRecord::Migration[7.1]
  def change
    create_table :stream_segments do |t|
      t.references :stream
      t.decimal :relative_timestamp
      t.decimal :duration

      t.timestamps
    end
  end
end
