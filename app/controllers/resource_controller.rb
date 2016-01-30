class ResourceController < ApplicationController
  include LocaleHelper

  before_filter :authenticate_user!
  before_filter :set_locale
  
  # GET /maps/1
  # GET /maps/1.json
  def map
    @map = Map.find_by _id: ApplicationHelper.check_int_param(params[:id])

    #respond_to do |format|
    #  format.json { render json: @map }
    #end

    render json: @map
  end
  
  # GET /weapons/active
  def weapons_active
    @user = current_user

    @weapons = Weapon.where 'user_id' => @user._id, 'active' => true
    render json: @weapons
  end

  def ball
    @ball = Ball.find_by _id: ApplicationHelper.check_int_param(params[:id])

    render json: @ball
  end

  def game_event
    @game_event = GameEvent.find_by _id: ApplicationHelper.check_int_param(params[:id])

    render json: @game_event
  end
  
  def animation
    @animation = Animation.find_by _id: ApplicationHelper.check_int_param(params[:id])

    render json: @animation
  end

  def game_play 
    @game_play = GamePlay.find_by _id: ApplicationHelper.check_int_param(params[:id])

    render json: @game_play
  end

  def complete_game_play
    @game_play = GamePlay.find(ApplicationHelper.check_int_param params[:id])

    render json: @game_play.as_json({
      include: {
        map: {
          include: {
            map_balls: {
              include: {
                ball: {}
              }
            }
          }
        }
      }
    })
  end

  def game_plays 
    @game_plays = GamePlay.all.asc(:_id)

    render json: (@game_plays.map do |x| 
      res = x.as_json(only: [:_id, :name, :max_players, :allowed_type, :texture])
      res[:probabilities] = x.game_play_probabilities.as_json
      res
    end)
  end

  def game_result
    @game_result = GameResult.find_by _id: ApplicationHelper.check_object_id_param(params[:id])

    render json: @game_result
  end
end
