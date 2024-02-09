# == Schema Information
#
# Table name: channels
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Channel < ApplicationRecord
  has_one :thumbnail_image
end
