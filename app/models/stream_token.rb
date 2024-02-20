# == Schema Information
#
# Table name: stream_tokens
#
#  id         :integer          not null, primary key
#  revoked_at :datetime
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_stream_tokens_on_user_id  (user_id)
#
class StreamToken < ApplicationRecord
end
