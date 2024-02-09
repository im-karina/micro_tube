class CreateVideos < ActiveRecord::Migration[7.1]
  def change
    create_table :videos do |t|
      t.string :slug
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
