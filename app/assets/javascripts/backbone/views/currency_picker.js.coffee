#= require ./popup

class MegaballWeb.Views.CurrencyPickerView extends MegaballWeb.Views.ScalablePopupView

  events:
    'click .do-star:not(.inactive)':'do_star'
    'click .do-coin:not(.inactive)':'do_coin'

  style: 'contrast'
  render_params: {
    heading: 'выбор валюты' }

  initialize: ->
    @stars = @options.stars ? -1
    @coins = @options.coins ? -1
    @options.text = $("#currency_picker_template").html()
    @options.buttons = ['close']
    super @options
    @on = MegaballWeb.Views.MasterView::on

  set_content: ->
    super
    @fill 'star', @stars
    @fill 'coin', @coins

  fill: (currency, amount) ->
    if amount >= 0
      @$el.find(".price-list.#{currency}").html(amount)
      @$el.find(".do-#{currency}").removeClass('inactive')
    else
      @$el.find(".price-list.#{currency}").html('---')
      @$el.find(".do-#{currency}").addClass('inactive')

  do_star: ->
    @trigger 'pick', 'stars', @stars
    @dispose()

  do_coin: ->
    @trigger 'pick', 'coins', @coins
    @dispose()
