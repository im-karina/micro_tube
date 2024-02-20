class CreateStreams < ActiveRecord::Migration[7.1]
  def change
    create_table :streams do |t|
      t.string :slug, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
