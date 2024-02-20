module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation { self.slug ||= SecureRandom.base58(23) }
  end

  def to_param
    slug
  end
end

