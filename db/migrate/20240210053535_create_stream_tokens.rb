class CreateStreamTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :stream_tokens do |t|
      t.references :user

      t.string :token
      t.datetime :revoked_at

      t.timestamps
    end
  end
end
