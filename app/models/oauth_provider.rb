class OauthProvider
  include Mongoid::Document

  field :provider, :type => String
  field :uid, :type => String

  attr_accessible :provider, :uid

  embedded_in :user

  def as_json(options={})
    super :only => [:provider, :uid]
  end

  index({uid:1, provider: 1}, {})
end
