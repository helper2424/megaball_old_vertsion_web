class RouletteController < ApplicationController
  include ErrorsHelper
  include PriseHelper

  def items
    render json: RouletteItem.active.as_json(except: [:created_at, :updated_at])
  end

  def roll
    user = current_user
    return render_error :no_tickets if user.roulette_tickets <= 0
    items = RouletteItem.active.reject(&:not_available).to_a
    rand_k = rand 100
    item = items.reject{ |x| x.probability_percent < rand_k }.sample
    
    prise_for(user).with(item, :roulette).give!
    user.roulette_tickets -= 1
    user.save

    render json: item.as_json_with_random
  end

  # GET /roulette/chest
  def chest
    render json: RouletteItem.active.find_by(chest: true)
  end
end
