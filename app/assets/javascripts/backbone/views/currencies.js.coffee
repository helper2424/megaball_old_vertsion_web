class MegaballWeb.Views.CurrenciesView extends MegaballWeb.Views.MasterView
  el:'#header .currency'
  stars: '#star_currency'
  coins: '#coin_currency'
  shine_template: "<div class='shine'></div>"
  shine_box: width: 21, height: 21

  events:
    'click':'clicked'
    #'click':'test'
    #'click':'stub'

  initialize: ->
    super
    console.log("Initialization Currencies view")
    if window.special_offer
      $('.button.votes').click @context(@special_offer)
    @router = @options.router
    @current_user = @options.user
    @prev = {}
    @bank = new MegaballWeb.Views.BankView el: $('.bank'), router: @router
    @bank.hide()
    @current_user.on 'sync', @context @render
    @render()

  render: ->
    console.log("Render Currencies view")
    if @current_user?
      $(@coins).attr('data-hint',@current_user.get('coins'))
      $(@stars).attr('data-hint',@current_user.get('stars'))
      @render_currency 'stars', @stars
      @render_currency 'coins', @coins

  render_currency: (key, el) ->
    $(el).text @format_currency @current_user.get key
    if @prev[key]? and @current_user.get(key) != @prev[key]
      @animate $(el).parent('.currency-wrapper')
    @prev[key] = @current_user.get(key)

  clicked: (e) ->
    el = $ e.currentTarget
    window.u_play_sound 6
    @navigate el.attr 'data-currency'

  navigate: (tab) ->
    @router.modal_begin()
    @bank.navigate tab

  test: (e) ->
    @animate $(@stars).parent('.currency-wrapper')

  animate: (el) ->
    box = {
      left: el.width() - @shine_box.width
      top: el.height() - @shine_box.height
    }

    for x in [0..1000] by 100
      setTimeout((=>
        shine = $ @shine_template
        shine.css({
          left: _.random(0, box.left) + "px"
          top: _.random(0, box.top) + "px"
        }).hide()
        el.append(shine)
        shine.fadeIn('slow', ->
          $(@).fadeOut('slow', ->
            $(@).remove()))
      ), x)

  format_currency: (val) -> val.format_with_k()

  stub: ->
    MegaballWeb.Views.PopupView.alert 'Пополнение счета пока недоступно!'

  special_offer: ->
    @router.modal_begin()
    @bank.navigate 'star'
    window.payment_source.special_offer()
