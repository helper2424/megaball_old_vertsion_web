class VkInfoCollector
  include Sidekiq::Worker

  def perform
    #config = MEGABALL_IFRAME_CONFIG['vk']
    vk_app = VK::Application.new

    last_id = 0
    max = 1000

    while true
      target = User.where(:_id.gt => last_id).order_by([:_id, :asc]).limit(max).entries
      break if target.count <= 0
      last_id = target.last._id

      puts "...."
      puts "requesting #{target.count} user infos..."
      puts "first_id: #{target.first._id} last_id: #{last_id}"
      puts "..."

      uids = Hash[target.map do |u| 
        oauth = u.oauth_providers
        [oauth[0].uid, u]
      end]

      res = vk_app.vk_call('users.get', { user_ids: uids.keys.join(','), fields: 'sex,bdate' })

      res.each do |info|
        user = uids[info["uid"].to_s]
        unless user.nil?
          user.sex = if info["sex"] == 2 then 'male' \
                     elsif info["sex"] == 1 then 'female' \
                     else 'unknown' end
          user.bdate = info["bdate"]
          user.save
        end
      end
    end
  end
end
