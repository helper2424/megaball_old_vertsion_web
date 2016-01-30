class Payment::FbController < ApplicationController 
  include LocaleHelper

  before_filter :set_locale

  def callback
    puts "Callback: #{params.as_json}"
    render json: {}
  end

  def realtime_update
    puts "Realtime update: #{params.as_json}"
    hub_challenge = params['hub.challenge']
    render json: hub_challenge
  end

  def product
    @currency = params[:currency]
    @currency = (@currency == 'coin') ? 'coin' : 'star'
    puts "Product: #{params.as_json}"
    render layout: false
  end
end
