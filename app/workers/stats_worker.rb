require 'net/http'
require 'uri'

class StatsWorker
  #include Sidekiq::Worker

  def perform event, info={}

    uri = URI.parse MEGABALL_CONFIG["stats"]["address"]

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_form_data(self.parse_info event, info)

    http.request(req)
  end

  def self.perform_for_user user, event, info={}
    oauth = user.oauth_providers[0]

    data = {
      user_id: user.id,
      user_category: user.category,
      sex: user.sex,
      bdate: user.bdate,
      social_network: oauth.nil? ? "unspecified" : oauth.provider,
      social_uid: oauth.nil? ? "unspecified" : oauth.uid,
    }

    self.perform_async(event, data.merge!(info))
  end

  # faking sending stats
  def self.perform_async event, info={}
    info = info.symbolize_keys
    info = self.parse_info event, info

    StatEntry.create event: event, info: info
  end

  def self.parse_info event, info={}
    info = info.symbolize_keys
    info[:custom] ||= {}

    { 
      "event"          => (event || ""),
      "user_id"        => (info[:user_id] || 0),
      "user_category"  => (info[:user_category] || "").to_s,
      "sex"            => (info[:sex] || "").to_s,
      "bdate"          => (info[:bdate] || "").to_s,
      "date"           => Time.now.to_i,
      "social_network" => (info[:social_network] || "default"),
      "social_uid"     => (info[:social_uid] || "0"),
      "ref"            => (info[:ref] || ""),
      "item"           => (info[:item] || ""),
      "quantity"       => (info[:quantity] || 0).to_f,
      "secret_key"     => MEGABALL_CONFIG["stats"]["secret_key"],
      "custom"         => (info[:custom] || {}).as_json
    }
  end
end
