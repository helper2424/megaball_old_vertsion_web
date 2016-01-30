require 'json'
require 'digest'
require 'uri'
require 'net/http'

class GameAnalytics
  include Sidekiq::Worker

  def perform config, category, user_id, event_id, value=nil, area=nil    
    game_key = config['game_key']
    secret_key = config['secret_key']
    endpoint_url = config['endpoint_url']

    message = {}
    message["event_id"] = event_id
    message["user_id"] = user_id
    message["session_id"] = "serverSession"
    message["build"] = config['build']

    if category == "design"
      message['value'] = value unless value.nil?
      message['area'] = area unless area.nil?
    elsif category == "user"

    elsif category == 'business'

    elsif category == 'error'
      
    end

    json_message = message.to_json
    json_authorization = Digest::MD5.hexdigest(json_message+secret_key)

    url = "#{endpoint_url}/#{game_key}/#{category}"
    uri = URI(url)
    req = Net::HTTP::Post.new(uri.path)
    #req.set_form_data(message)
    req.body= json_message
    req['Authorization'] = json_authorization

    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(req)
    end
  end
end