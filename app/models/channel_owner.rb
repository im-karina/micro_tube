# == Schema Information
#
# Table name: channel_owners
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  channel_id :integer
#  user_id    :integer
#
# Indexes
#
#  index_channel_owners_on_channel_id  (channel_id)
#  index_channel_owners_on_user_id     (user_id)
#
class ChannelOwner < ApplicationRecord
  belongs_to :channel
  belongs_to :user
end
