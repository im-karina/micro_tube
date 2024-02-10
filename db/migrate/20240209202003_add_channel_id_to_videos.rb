class AddChannelIdToVideos < ActiveRecord::Migration[7.1]
  def change
    add_reference :videos, :channel
  end
end
