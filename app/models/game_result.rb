class GameResult
	include Mongoid::Document

  field :game_play, type: Integer
  field :timestamp, type: Integer
  field :room_type, type: Integer, default: 1 # 1 - fast, 2 - train, 3 - arena, 4 - champ

  field :bet_stars, type: Integer, default: 0
  field :bet_coins, type: Integer, default: 0

  embeds_many :team_game_results

  index 'team_game_results.user_game_results._id' => 1, :timestamp => 1

  scope :last_for_user, ->(user) { 
    where(:'team_game_results.user_game_results._id' => user.id).order_by([:timestamp, :desc]) 
  }

  accepts_nested_attributes_for :team_game_results

  def string_room_type
    case self.room_type
    when 1 then :fast
    when 2 then :train
    when 3 
      bet_type = (self.bet_stars > 0) ? 'stars' : 'coins'
      "arena_#{bet_type}".to_sym
    when 4 then :champ
    end
  end

  def get_user_result(user)
    team_id = 0
    user_result = nil

    for team in team_game_results
      user_result = team.user_game_results.find(user._id)
      break unless user_result.nil?
      team_id += 1
    end

    return {
      team_id: team_id,
      user_result: user_result 
    } unless user_result.nil?
    return nil
  end
end
