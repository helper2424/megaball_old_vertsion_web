class MbController < ApplicationController

  layout 'map_builder'

  before_filter :authenticate_user!
    
  def index
  end

  def maps
    maps = []

    Map.each do |map|
      maps << map._id
    end

    render json: maps
  end

  def map
    map = Map.find ApplicationHelper.check_int_param params[:id]

    puts params
  end

  def save
    return unless user.admin

    map = params[:map]

    status = 0

    if map.nil?
      status = 0
    else
      map_id = map[:_id]

      puts "map id: #{map_id}"
      map.delete "_id"
      if map_id.nil? or map_id == 0 or Map.where(_id: map_id).count == 0
        puts "new map"
      else
        new_map = Map.new map
        new_map.save!

      end
    end

    render json: {status: status}
  end
end
