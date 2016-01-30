# -*- encoding : utf-8 -*-

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include UsersHelper

  # Include default devise modules. Others available are: # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise  :database_authenticatable, :rememberable, :trackable, :validatable,:omniauthable

  auto_increment :_id, :seed  => 0

  ## Database authenticatable
  field :email,              :type => String,  :default => ""
  field :encrypted_password, :type => String,  :default => ""
  field :admin,              :type => Boolean, :default => false
  field :locale,             :type => String,  :default => "ru"
  field :zone,               :type => String,  :default => "russian"
  field :account_version,    :type => Integer, :default => 2
  field :category,           :type => String,  :default => ""

  field :sex,                :type => String, :default => "unknown"
  field :bdate,              :type => String, :default => "unknown"
  
  ## Recoverable
  #field :reset_password_token,   :type => String
  #field :reset_password_sent_at, :type => Time
  #

  ## Money
  field :add_imagine, :type => Integer, :default => 0

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String
  field :token,              :type => Integer
  field :exp_date,           :type => Integer
  field :in_game,            :type => Boolean, :default => false
  field :room_type,          :type => Integer, :default => 0 # what in_game type ? 1 - fast, 2 - training
  field :want_spectate,      :type => Boolean, :default => false
  field :first_time,         :type => Boolean, :default => true
  field :referrer,           :type => String, :default => ""

  field :last_accessed,      :type => Time
  field :last_daily_bonus,   :type => Time, :default => nil
  field :days_in_row,        :type => Integer, :default => 0
  field :last_session_save,  :type => Integer, :default => 0
  
  ## Drawable
  field :experience,            :type => Integer, :default => 0
  field :loss_of_experience_without_vip, :type => Integer, :default => 0 #Недополученный опыт за игру без випа
  field :last_experience,       :type => Integer, :default => 0
  field :energy,                :type => Integer, :default => 30
  field :energy_after_volcano,  :type => Integer, :default => 30
  field :energy_restore_factor, :type => Float, :default => 0.5
  field :last_energy_update,    :type => Time, :default => nil
  field :last_volcano_update,   :type => Time, :default => nil
  field :last_mana_update,      :type => Time, :default => nil
  field :last_daily_mana,       :type => Integer, :default => 0
  field :group_id,              :type => Integer, :default => 0
  field :room_id,               :type => String, :default => ''
  field :server,                :type => String, :default => ''
  field :total_mana_usage,      :type => Integer, :default => 0

  ## User Pumping
  field :leg_length,          :type => Integer, :default => 0
  field :kick_power,          :type => Integer, :default => 0
  field :move_force,          :type => Integer, :default => 0
  field :super_kick_power,    :type => Integer, :default => 0
  field :points,              :type => Integer, :default => 0
  field :nitro_speed,         :type => Integer, :default => 0
  field :mana_top,            :type => Integer, :default => 0

  #Параметры 
  field :leg_length_buffer,          :type => Integer, :default => 0
  field :kick_power_buffer,          :type => Integer, :default => 0
  field :move_force_buffer,          :type => Integer, :default => 0
  field :nitro_speed_buffer,         :type => Integer, :default => 0
  field :mana_top_buffer,            :type => Integer, :default => 0

  #Perks

  #Nitro perks
  field :perk_nitro_repair_latency,  :type => Integer, :default => 0
  field :perk_nitro_repair_speed,    :type => Integer, :default => 0
  field :perk_nitro_dribbling_user,  :type => Integer, :default => 0

  #Kick power perks 
  field :perk_super_kick_repair_enemy_kick_ball,       :type => Integer, :default => 0
  field :perk_super_kick_repair_enemy_kick_player,     :type => Integer, :default => 0
  field :perk_super_kick_slowdown_enemy,               :type => Integer, :default => 0  

  #Mana perks
  field :perk_mana_repair_speed,         :type => Integer, :default => 0
  field :perk_mana_chance_to_return,     :type => Integer, :default => 0
  field :perk_mana_start_with_mana,      :type => Integer, :default => 0  
  
  #Statistics
  field :last_match_id,       :type => String, :default => ''
  field :last_collection_item,  :type => Hash, :default => {}
  field :last_match_ids,      :type => Array, :default => []
  field :played_fast_matches, :type => Integer, :default => 0
  field :ended_fast_matches,  :type => Integer, :default => 0
  field :played_arenas,       :type => Integer, :default => 0
  field :created_arenas,      :type => Integer, :default => 0
  field :created_rooms,       :type => Integer, :default => 0
  field :played_trainings,    :type => Integer, :default => 0
  field :played_in_group,     :type => Integer, :default => 0
  field :distance_walked,     :type => Float, :default => 0
  field :nitro_used,          :type => Float, :default => 0
  field :ball_kicks,          :type => Integer, :default => 0
  field :player_kicks,        :type => Integer, :default => 0
  field :goals,               :type => Integer, :default => 0
  field :goal_passes,         :type => Integer, :default => 0
  field :gate_saves,          :type => Integer, :default => 0
  field :rod_hits,            :type => Integer, :default => 0
  field :wins,                :type => Integer, :default => 0
  field :draws,               :type => Integer, :default => 0
  field :fails,               :type => Integer, :default => 0
  field :rating,              :type => Integer, :default => 0
  field :daily_rating,        :type => Integer, :default => 0
  field :monthly_rating,      :type => Integer, :default => 0
  field :daily_rating_day,    :type => Integer, :default => 0
  field :monthly_rating_month,:type => Integer, :default => 0
  field :best_player,         :type => Integer, :default => 0
  field :friends_count,       :type => Integer, :default => 0
  field :skill_usage,         :type => Hash, :default => {}
  field :dynamic_stats,       :type => Hash, :default => {}
  field :have_seen_menu,      :type => Boolean, :default => false
  field :plugin_status,       :type => String, :default => "not_set"
  field :place,               :type => Integer, :default => 0
  field :daily_place,         :type => Integer, :default => 0
  field :monthly_place,       :type => Integer, :default => 0
  field :goals_place,         :type => Integer, :default => 0
  field :passes_place,        :type => Integer, :default => 0
  field :gate_saves_place,    :type => Integer, :default => 0

  #User skin
  field :hair,  :type => Integer, :default => 1
  field :eye,   :type => Integer, :default => 1
  field :mouth, :type => Integer, :default => 1
  field :skin,  :type => Integer, :default => 0

  #Available user skins
  field :avail_hair,  :type => Array, :default => [0,1,4,7]
  field :avail_eye,   :type => Array, :default => [0,1,2,4,5]
  field :avail_mouth, :type => Array, :default => [0,1,5]

  field :exclusive_count, type: Integer, default: 0
  
  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String
  
  field :champ_id, :type => Integer, :default => 0
  field :champ_cell_id, :type => Integer, :default => 0
  field :club_id, :type => Integer, :default => 0

  ## Game filters
  field :filters_enabled, :type => Boolean, :default => false # enabled when creating something, or quick match
  embeds_one :room

  ## Settings
  field :sound_on, :type => Boolean, :default => true
  field :music_on, :type => Boolean, :default => true
  field :fullscreen_on, :type => Boolean, :default => false
  
  ## Invite system
  field :active, :type => Boolean, :default => false

  ## Achievements
  embeds_many :user_achievement

  ## Collections
  field :collections_done, type: Integer, default: 0
  embeds_many :user_collection

  ## Learning
  field :stage, :type => Integer, :default => 0
  field :fresh_man_tour_finished, :type => Boolean, :default => false
  field :money_for_first_games_received, :type => Boolean, :default => false

  ## Mail
  field :last_read_mail,  :type => Integer, :default => 0
  field :last_shown_news, :type => Integer, :default => 0

  ## Results
  field :last_game_result_id, :type => String, :default => ""

  ## Controls
  embeds_one :user_control
  after_initialize :build_user_control

  ## Daily
  field :roulette_tickets, type: Integer, default: 1
  field :daily_mission_backup, type: Hash, default: {}
  field :last_roulette_ticket_given, type: Time, default: 0

  ## Currencies
  field :coins, :type => Integer, :default => 100
  field :stars, :type => Integer, :default => 3
  field :add_coins, :type => Integer, :default => 0
  field :add_stars, :type => Integer, :default => 0

  ## Social
  field :last_energy_notification, :type => Time, :default => 0

  embeds_many :pending_money
  
  ## Bannable
  field :chat_banned, :type => Boolean, :default => false
  
  ## Validations
  field :name
  validates_presence_of :name
  validates_uniqueness_of :name, :email, :case_sensitive => false
  validate :skin_validation

  field :user_agent, type: String, default: ""

  attr_accessible :perk_nitro_repair_latency, :perk_nitro_repair_speed, :perk_nitro_dribbling_user, 
    :perk_super_kick_repair_enemy_kick_ball, :perk_super_kick_repair_enemy_kick_player, 
    :perk_super_kick_slowdown_enemy, :perk_mana_repair_speed, :perk_mana_chance_to_return, 
    :perk_mana_start_with_mana,:nitro_speed, :nitro_speed_buffer, :mana_top, :mana_top_buffer, 
    :sex, :bdate, :user_agent, :coins, :stars, :add_coins, :add_stars, :name, :email, :password, 
    :remember_me, :token, :exp_date, :radius, :texture_url, :nitro_max, :weight, :friction_on_move, 
    :friction_on_kick, :kick_power, :move_force, :leg_length, :acceleration, :nitro_force, 
    :nitro_spend_speed, :nitro_restore_speed, :room, :sound_on, :music_on, :fullscreen_on, :active, 
    :stage, :avail_mouth, :avail_eye, :avail_hair, :in_game, :last_experience, :points, :rating, 
    :daily_rating, :monthly_rating, :user_achievement, :skill_usage, :dynamic_stats, :daily_rating_day, 
    :monthly_rating_month, :user_collection_item, :user_controls, :server, :first_time, :collections_done, 
    :best_player, :last_accessed, :days_in_row, :referrer, :last_daily_bonus, :fresh_man_tour_finished, 
    :have_seen_menu, :last_collection_item, :chat_banned, :pending_money, :money_for_first_games_received, 
    :ended_fast_matches, :roulette_tickets, :locale, :zone, :daily_mission_backup

  # Include oauth providers for omniauth
  embeds_many :oauth_providers

  # Indexes
  index :"oauth_providers.uid" => 1, :"oauth_providers.provider" => 1

  index :place => 1
  index :daily_place => 1
  index :monthly_place => 1
  index :goals_place => 1
  index :passes_place => 1

  index :goal_passes => 1
  index :goals => 1
  index :monthly_rating => 1, :monthly_rating_month => 1
  index :daily_rating => 1, :daily_rating_day => 1
  index :rating => 1

  after_create :create_acid

  def skin_validation
    errors.add :hair unless avail_hair.include? hair
    errors.add :eye unless avail_eye.include? eye
    errors.add :mouth unless avail_mouth.include? mouth
  end

  def get_dynamic_stat key 
    self.dynamic_stats ||= {}
    self.dynamic_stats[key.to_s]
  end

  def set_dynamic_stat key, value
    self.dynamic_stats ||= {}
    self.dynamic_stats[key.to_s] = value
  end

  def inc_dynamic_stat key, value=1
    set_dynamic_stat key, ((get_dynamic_stat(key) || 0).to_i + value)
  end

  def self.find_for_provider_oauth(provider, auth, signed_in_resource=nil)

    user = User.where('oauth_providers.provider' => provider, 
      'oauth_providers.uid' => auth[:uid].to_s).first

    if signed_in_resource 
      if user
        if signed_in_resource == user
          user = signed_in_resource
        else
          user = nil
        end
      else
        user = signed_in_resource
        user.oauth_providers << OauthProvider.new(provider: provider, 
          uid: auth[:uid])
      end
    else
      unless user
        user = UsersHelper.fresh_user({
          name: self.new_unique_name(auth[:info][:nickname], provider, auth[:uid]),
          email: self.new_unique_email(auth[:info][:email], provider, auth[:uid]),
          password: Devise.friendly_token[0,20],
          locale: auth[:locale] || 'russian',
          zone: auth[:zone] || 'ru',
          sex: auth[:info][:sex],
          bdate: auth[:info][:bdate]
        })
        user.oauth_providers << OauthProvider.new(provider: provider,
                                                  uid: auth[:uid])
        user.save
        UsersHelper.give_free_weapons user, [13] #Give "alkashka" to user (:

        StatsWorker.perform_for_user(user, :new_user, { ref: auth[:ref] })

        #Install game event
        GameAnalytics.perform_async GAMEANALYTICS_CONFIG, 'design', user._id, "GameInstalled"
      end
    end

    user
  end

  def self.new_unique_name name, provider = nil, uid = nil
    new_name = name

    new_name = provider.to_s + '_' + uid.to_s if (new_name.nil? || new_name.empty?) && provider && uid
    new_name = self.random_string if new_name.nil? || new_name.empty?
    new_name += Time.now.to_i.to_s

    3.times do
      unless User.where(:name => new_name).exists?
        return new_name
      else
        new_name = new_name + self.random_string
      end
    end

    new_name
  end

  def self.new_unique_email email, provider = nil, uid = nil
    new_email = email

    new_email = uid.to_s + '@' + provider.to_s + '.com' if (new_email.nil? || new_email.empty? || !(/^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i =~ new_email)) && provider && uid
    new_email = self.random_string if new_email.nil? || new_email.empty?
    new_email = Time.now.to_i.to_s + new_email

    3.times do
      unless User.where(:email => new_email).exists?
        return new_email
      else
        new_email = self.random_string + new_email
      end
    end

    new_email
  end

  def self.random_string
    (0..4).map{rand(9).to_s}.join
  end

  def active?
    self.active
  end

  def as_json(options={})
    if options.empty?
      json = super :only => [:_id, :perk_nitro_repair_latency, :perk_nitro_repair_speed, 
        :perk_nitro_dribbling_user, :perk_super_kick_repair_enemy_kick_ball, 
        :perk_super_kick_repair_enemy_kick_player, :perk_super_kick_slowdown_enemy, 
        :perk_mana_repair_speed, :perk_mana_chance_to_return, :perk_mana_start_with_mana, 
        :name, :radius, :nitro_speed, :nitro_speed_buffer, :mana_top, :mana_top_buffer, 
        :texture_url, :nitro_force, :nitro_max, :weight, :friction_on_move, :friction_on_kick, 
        :kick_power, :move_force, :leg_length, :acceleration, :energy, :energy_after_volcano, 
        :experience, :hair, :eye, :mouth, :filters_enabled, :skin, :room_type, :room_id, 
        :want_spectate, :sound_on, :music_on, :fullscreen_on, :stage, :group_id, :in_game, 
        :points, :super_kick_power, :coins, :stars, :rating, :daily_rating, :monthly_rating, 
        :daily_rating_day, :monthly_rating_month, :friends_countm, :avail_hair, :avail_eye, 
        :avail_mouth, :energy_restore_factor, :server, :collections_done, :days_in_row, 
        :fresh_man_tour_finished, :have_seen_menu, :last_collection_item, :plugin_status, 
        :ended_fast_matches, :roulette_tickets, :first_time, :locale, 
        :played_fast_matches, :played_trainings, :loss_of_experience_without_vip,:leg_length_buffer, 
        :kick_power_buffer, :move_force_buffer  ]
      json[:last_energy_update] = self.last_energy_update.to_i
      json[:last_volcano_update] = self.last_volcano_update.to_i
      json[:user_control] = self.user_control.as_json
    else
      json = super options
    end

    json
  end

  def days_in_game
    if self.oauth_providers.count > 0
      (Time.now.to_i - self.oauth_providers[0].id.generation_time.to_i) / 60 / 60 / 24
    else
      0
    end
  end

  def profile_url
    p = oauth_providers.first

    result = ''

    if not p.nil?
      result = case p.provider
        when 'vkontakte' then '//vk.com/id'+p.uid
        when 'mailru' then '//my.mail.ru/mail/'+p.uid+'/'
        when 'odnoklassniki' then '//www.odnoklassniki.ru//profile/'+p.uid+'/'
        else '//?uid='+ p.uid
      end
    end

    result
  end

  def public_json
    json = as_json :only => [
      :_id, :name, :experience, :hair, :eye, :mouth, :hair, 
      :rating, :daily_rating, :monthly_rating, :group_id, 
      :leg_length, :kick_power, :move_force, :super_kick_power, 
      :last_daily_bonus, :ended_fast_matches, :played_fast_matches,
      :gate_saves, :goals, :wins, :fails, :goal_passes, :place,
      :monthly_place, :daily_place, :goals_place, :passes_place,     
      :leg_length_buffer, :kick_power_buffer, :move_force_buffer,  
      :nitro_speed, :nitro_speed_buffer, :mana_top, :mana_top_buffer
    ]
    json[:last_energy_update] = self.last_energy_update.to_i
    json[:last_volcano_update] = self.last_volcano_update.to_i
    json[:sign_in_timestamp] = self.last_sign_in_at.to_i
    json[:oauth_providers] = oauth_providers.map{ |x| x.as_json }
    json
  end

  # Do not use it in transactions, because non-blocking
  def acid
    return AcidUser.find self._id
  end

  def level
    user_default = UserDefault.first
    levels = []
    levels = user_default.levels if user_default and user_default.levels
    (levels.select {|bound| bound <= self.experience}).length
  end

  def set_energy(val)
    self.energy = val
    self.energy = 0 if self.energy < 0
    self.energy
  end

  def user_achievement_by_id(id)
    i = self.user_achievement.index{ |x| x.achievement == id }
    if i.nil?
      self.user_achievement.new achievement: id
    else
      self.user_achievement[i]
    end
  end

  def social
    if oauth_providers.nil? or oauth_providers.length == 0
      SocialUtils.empty
    else
      prov = oauth_providers[0]
      case prov.provider
      when 'vkontakte' then VkUtils.new prov.uid
      else SocialUtils.empty
      end
    end
  end

  def club
    return nil if club_user.nil?
    @club ||= Club.find(club_user.cid)
  end

  def club_user
    @club_user ||= ClubUser.where(uid: self._id).first
  end

  def days_since_last_daily_bonus
    _last_daily_bonus = self.last_daily_bonus
    _last_daily_bonus_stamp = _last_daily_bonus.month * 100 + _last_daily_bonus.day
    _current_time = Time.now.gmtime
    _current_time_stamp = _current_time.month * 100 + _current_time.day
    _current_time_stamp - _last_daily_bonus_stamp
  end

  def been_today
    return false if self.last_sign_in_at.nil?
    ((Time.now - self.last_sign_in_at) / 1.day).floor <= 0
  end

  def attr_by_string path, default = nil
    attr = path.split('/').inject(self) { |h, node| h[node] }
    attr.nil? ? default : attr
  end

  private

  def create_acid
    AcidUser.create! id: self._id, real_balance: 2, imagine_balance: 10
  end

  def build_user_control
    return unless self.user_control.nil?
    self.user_control = UserControl.new
  end

  accepts_nested_attributes_for :room
  accepts_nested_attributes_for :user_achievement
  accepts_nested_attributes_for :user_collection
  accepts_nested_attributes_for :user_control
  accepts_nested_attributes_for :pending_money
  accepts_nested_attributes_for :oauth_providers

  attr_accessible :room_attributes
  attr_accessible :user_achievement_attributes
  attr_accessible :user_collection_attributes
  attr_accessible :user_control_attributes
  attr_accessible :pending_money_attributes
  attr_accessible :oauth_providers_attributes
  attr_accessible :last_shown_news
  attr_accessible :last_read_mail
  attr_accessible :filters_enabled
  attr_accessible :skin
  attr_accessible :mouth
  attr_accessible :eye
  attr_accessible :hair
  attr_accessible :fails
  attr_accessible :draws
  attr_accessible :wins
  attr_accessible :rod_hits
  attr_accessible :gate_saves
  attr_accessible :goal_passes
  attr_accessible :goals
  attr_accessible :super_kick_power
  attr_accessible :group_id
  attr_accessible :experience
  attr_accessible :energy_restore_factor
  attr_accessible :energy
  attr_accessible :energy_after_volcano
  attr_accessible :want_spectate

  has_many :energy_request_friend, class_name: 'EnergyRequest', inverse_of: :friend
  has_many :energy_request_receiver, class_name: 'EnergyRequest', inverse_of: :receiver
end
