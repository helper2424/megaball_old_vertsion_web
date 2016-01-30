module GameResultHelper
  def self.count_last_match(user)
    game_result = GameResult.find user.last_match_id
    unless game_result.nil?
      user_result = game_result.get_user_result(user)
      user_result = user_result[:user_result] unless user_result.nil?
      unless user_result.nil?
        case game_result.room_type
        when 1
          user.acid.contribute_currency user_result.stars, :real, comment='game_result' unless user_result.stars.nil?
          user.acid.contribute_currency user_result.coins, :imagine, comment='game_result' unless user_result.coins.nil?
        when 3
          user.acid.contribute_currency user_result.stars, :real, comment='game_result_arena' unless user_result.stars.nil?
          user.acid.contribute_currency user_result.coins, :imagine, comment='game_result_arena' unless user_result.coins.nil?
        end
      end
    end
  end

  def self.count_match_revenue(user, match_id)
    game_result = GameResult.find match_id
    unless game_result.nil?
      user_result = game_result.get_user_result(user)
      user_result = user_result[:user_result] unless user_result.nil?
      unless user_result.nil?
        case game_result.room_type
        when 1
          user.acid.contribute_currency user_result.stars, :real, comment='game_result' unless user_result.stars.nil?
          user.acid.contribute_currency user_result.coins, :imagine, comment='game_result' unless user_result.coins.nil?
        when 3
          user.acid.contribute_currency user_result.stars, :real, comment='game_result_arena' unless user_result.stars.nil?
          user.acid.contribute_currency user_result.coins, :imagine, comment='game_result_arena' unless user_result.coins.nil?
        end
      end
    end
  end
end
