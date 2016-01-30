module ClubsHelper

  def sanitize(str)
    ActionController::Base.helpers.sanitize(str, tags: [])
  end
end
