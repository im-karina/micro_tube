class CreateChannelOwners < ActiveRecord::Migration[7.1]
  def change
    create_table :channel_owners do |t|
      t.references :channel
      t.references :user

      t.timestamps
    end
  end
end
