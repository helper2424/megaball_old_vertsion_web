class MegaballWeb.Views.OfferView extends MegaballWeb.Views.MasterView

  events:
    'click':'offer'

  initialize: ->
    super
    @type = @options.type
    @amount = @options.amount ? 0
    @real = @options.real ? 0
    @text = @options.text
    @bonus = @options.bonus ? 0
    @mb_currency_text = @options.mb_currency_text ? ''
    @render()

  render: ->
    @$el.find('.base').html @amount
    bonus = @$el.find('.bonus').html "+ #{@bonus}"
    @$el.find('.quote').html "#{@real} #{@text}"
    if @bonus > 0 then bonus.show()
    else bonus.hide()

  offer: (e) ->
    return unless $(e.currentTarget).is '.offer'
    window.payment_source.pay @type, @amount, @bonus, @real, @text, @mb_currency_text

class MegaballWeb.Views.BankView extends MegaballWeb.Views.MasterView

  template: _.template $("#bank_template").html()

  events:
    'click .close':'hide'
    'click .free-votes':'special_offer'

  imaginary_offers: window.payment.imaginary_offers

  real_offers: window.payment.real_offers

  initialize: ->
    super
    @visible = true
    @active_route = 'coin'
    @router = @options.router
    @render()

  render: ->
    el = $ @template()
    @$el.html ''
    @$el.append el
    @tabs = new MegaballWeb.Views.MainTabs el: @$el.find '.tabs'
    @tabs.on 'navigate', @context @navigate
    @render_offsers 'coin', @imaginary_offers
    @render_offsers 'star', @real_offers
    @navigate()

  render_offsers: (type, offers) ->
    for i, val of offers
      new MegaballWeb.Views.OfferView
        el: @$el.find(".#{type} .offer_#{i}")
        type: type
        amount: val[0]
        real: val[1]
        bonus: val[2]
        text: val[3]
        mb_currency_text: val[4]

  hide: (speed='fast') ->
    @visible = false
    @$el.hide speed
    @router.modal_end()

  show: (speed='fast') ->
    @visible = false
    @$el.show speed

  navigate: (tab) ->
    unless @visible then @show()
    return if @active_route? and @active_route == tab
    @active_route = tab if tab?
    @$el.find('.routes').hide()
    @$el.find(".routes.#{@active_route}").show()
    @tabs.set_current @active_route
   
  special_offer: ->
    window.payment_source.special_offer()
