class CreateStreamSlices < ActiveRecord::Migration[7.1]
  def change
    create_table :stream_slices do |t|
      t.references :stream
      t.decimal :start_time
      t.decimal :end_time

      t.timestamps
    end
  end
end
