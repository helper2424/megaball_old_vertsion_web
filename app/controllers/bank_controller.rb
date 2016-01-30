class BankController < ApplicationController

  before_filter :authenticate_user!

  def index
    @current_provider = params[:provider] || 'default'

    @payment = MEGABALL_CONFIG['payment'][@current_provider]
    @payment ||= MEGABALL_CONFIG['payment']['default']
    @currency = AcidCurrency.current @payment['gate']

    stars = @payment['real'].map do |pay|
      {
        amount: pay[0],
        bonus: pay[1],
        price: AcidCurrency.calculate_price(pay[0], @currency[:real])
      }
    end

    coins = @payment['imagine'].map do |pay|
      {
        amount: pay[0],
        bonus: pay[1],
        price: AcidCurrency.calculate_price(pay[0], @currency[:imagine])
      }
    end

    render json: {
      stars: stars,
      coins: coins,
      exchange_rate: {
        stars: @currency[:real].exchange_rate,
        coins: @currency[:imagine].exchange_rate,
      },
      currency_title: [
        translate(@payment['currency_name'], count: 1),
        translate(@payment['currency_name'], count: 2),
        translate(@payment['currency_name'], count: 11)
      ]
    }
  end
end
