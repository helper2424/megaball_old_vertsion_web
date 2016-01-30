class Room
  include Mongoid::Document

  field :name, type: String, default: 'default'
  field :type, type: Integer, default: 1
  field :players_cnt, type: Integer, default: 0
  field :spectators_cnt, type: Integer, default: 0
  field :ready, type: Boolean, default: false
  field :max_players, type: Integer, default: 0
  field :state, type: Integer, default: 0
  field :time_left, type: Integer, default: 0
  field :game_play, type: Integer, default: 0
  field :server_port, type: Integer, default: 0
  field :server_host, type: String, default: ''
  field :online, type: Integer, default: 0

  field :bet_stars, type: Integer, default: 0
  field :bet_coins, type: Integer, default: 0
  
  field :allow_spectators, type: Boolean, default: true
  field :allow_skills, type: Boolean, default: true

  field :level_from, type: Integer, default: 0
  field :level_to, type: Integer, default: 0
  field :owner_level, type: Integer, default: 0

  field :password, type: String, default: ""
  
  field :clubs, type: Array, default: []

  validates :name, length: { in: 3..25 }
  validates :type, inclusion: { in: 0..4 }
  validate :game_play_related_options
  validate :levels

  embedded_in :user

  index players_cnt: 1, type: 1

  def game_play_related_options
    return if type == 1
    play = GamePlay.find_by _id: game_play
    if play.nil?
      #errors.add :game_play, "#{game_play} doesn't exist"
      play = GamePlay.first

      self.game_play = play._id
    end
  end

  def levels
    if type != 1 and (level_from.nil? or (!level_to.nil? && level_from > level_to))
      errors.add :level_from, "level_from must be less or equal to level_to (#{level_from} > #{level_to})"
    end
  end

  def as_json(options={})
    options[:except] ||= :password
    json = super.as_json options
    json['lock'] = password? and !password.empty?
    json
  end
end
