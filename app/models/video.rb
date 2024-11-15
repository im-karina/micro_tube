# == Schema Information
#
# Table name: videos
#
#  id          :integer          not null, primary key
#  description :string
#  name        :string
#  slug        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  channel_id  :integer
#
# Indexes
#
#  index_videos_on_channel_id  (channel_id)
#
class Video < ApplicationRecord
  include Sluggable

  has_one_attached :source_video
  delegate :content_type, to: :source_video, prefix: true
  validates :source_video_content_type, inclusion: { in: %w[video/mp4] }

  belongs_to :channel
end
