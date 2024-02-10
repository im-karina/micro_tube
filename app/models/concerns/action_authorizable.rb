module ActionAuthorizable
  extend ActiveSupport::Concern

  def can_edit_channel?(channel)
    return true if admin?
    return owns_channel?(channel) if trusted?

    false
  end

  def can_create_channels?
    return true if admin?
    return true if trusted?

    false
  end

  def can_view_video?(video)
    return true if admin?
    return true if owns_channel?(video.channel)

    false
  end

  def can_edit_video?(video)
    return true if admin?
    return true if owns_channel?(video.channel)

    false
  end
end

