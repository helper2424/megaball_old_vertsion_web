class MegaballWeb.Views.PopupView extends MegaballWeb.Views.MasterView
  tagName: 'div'
  rootElement: $ '.popups'
  template: _.template $('#popup_template').html()
  render_params: {}

  @loading_show = (x) ->
    MegaballWeb.main_router.modal_begin()
    $('#loading').fadeIn('fast', ->x?())

  @loading_hide = (x) ->
    MegaballWeb.main_router.modal_end()
    $('#loading').fadeOut('fast', ->x?())

  @alert = (text) ->
    MegaballWeb.main_router.modal_begin()
    popup = new MegaballWeb.Views.PopupView text: '{{=data}}'
    popup.on 'any', ->
      MegaballWeb.main_router.modal_end()
      popup.dispose()
    popup.show data: text
    popup

  @confirm = ({text, ok, cancel}) ->
    MegaballWeb.main_router.modal_begin()
    popup = new MegaballWeb.Views.PopupView text: '{{=text}}', buttons: ['ok', 'cross']
    popup.on 'ok', -> ok() if ok?
    popup.on 'cross', -> cancel() if cancel?
    popup.on 'close', -> cancel() if cancel?
    popup.on 'any', ->
      MegaballWeb.main_router.modal_end()
      popup.dispose()
    popup.show text: text
    popup

  @prompt = ({text, prefill, ok, cancel, password}) ->
    MegaballWeb.main_router.modal_begin()
    data = $('.prompt').html()
    popup = new MegaballWeb.Views.PopupView text: data, buttons: ['ok', 'cross']
    val = -> popup.$el.find('.prompt_value').val()
    popup.on 'ok', -> ok val() if ok?
    popup.on 'cross', -> cancel val() if cancel?
    popup.on 'close', -> cancel val() if cancel?
    popup.on 'any', ->
      MegaballWeb.main_router.modal_end()
      popup.dispose()
    popup.show text: text, prefill: prefill, password: password
    popup

  initialize: () ->
    super
    @text = _.template @options.text
    @options.data = {} unless @options.data?
    @default_close = @options.default_close ? 'dispose'
    @callbacks = {}

    @buttons = @options.buttons
    @buttons = ['ok'] unless @buttons?
    
    @render()
    @on button, @context(@hide) for button in @buttons
    @on 'close', @context @[@default_close]
    @hider()

  on: (button, cb) ->
    selector = ".button"
    selector += ".#{button}" if button != 'any'
    @$el.find(selector).click(cb)

  off: (button) ->
    selector = ".button"
    selector += ".#{button}" if button != 'any'
    @$el.find(selector).off('click')

  render: ->
    @$el = $ @template _.extend @render_params, {
      buttons: @buttons }
    @rootElement.append @$el

  show: (data = {}, f = "fast") ->
    @set_content data
    @$el.finish().fadeIn 'fast'

  set_content: (data = {}) ->
    @$el.find('.content').html @text data

  hide: (f = "fast", cb = ->) ->
    @$el.finish().fadeOut(f, cb)

  dispose: ->
    @$el.fadeOut('fast', =>
      @$el.remove())

  hider: -> @$el.hide()

class MegaballWeb.Views.NotEnoughMoney extends MegaballWeb.Views.PopupView
  template: _.template $("#not_enough_money_template").html()

  @show = ->
    popup = new MegaballWeb.Views.NotEnoughMoney
    popup.show()
    popup

  events:
    'click .to-stars':'to_stars'
    'click .to-coins':'to_coins'
  
  initialize: ->
    @options.buttons = []
    @options.text = ''
    @on 'any', @context @dispose
    super @options

  to_stars: ->
    @dispose()
    MegaballWeb.currencies.bank.navigate 'star'

  to_coins: ->
    @dispose()
    MegaballWeb.currencies.bank.navigate 'coin'

class MegaballWeb.Views.HintView extends MegaballWeb.Views.PopupView
  template: _.template $("#hint_template").html()

  HIDE_DELAY = 5500

  @show = (target, text) ->
    popup = new MegaballWeb.Views.HintView text: text, target: target
    popup.show_delayed()
    popup

  initialize: ->
    @target = @options.target
    @options.buttons = []
    @on 'any', @context @dispose
    @to_show = false
    super @options

  show_delayed: ->
    @to_show = true
    setTimeout @context(@show), 200

  hide: ->
    super.hide()
    @dispose()
    @to_show = false

  show: ->
    @set_content()
    pos = @get_pos()
    return unless pos

    @$el.removeClass('up').removeClass('down')
    if pos.above then @$el.addClass('down')
    else @$el.addClass('up')

    @$el.css
      left: "#{pos.x}px"
      top: "#{pos.y}px"
    @$el.css visibility: 'visible', display: 'none'
    @$el.fadeIn 'fast'
    setTimeout @context(@hide), HIDE_DELAY

  get_pos: ->
    height = $(window).height()
    elw = @$el.width()
    elh = @$el.height()

    pos =
      x: @target.offset().left
      y: @target.offset().top

    return false if pos.x == 0 and pos.y == 0

    pos.x += (@target.width() - elw) / 2

    if pos.y + @target.height() + elh > height
      pos.above = true
      pos.y -= elh
    else
      pos.above = false
      pos.y += @target.height()

    pos.x = 0 if pos.x < 0
    pos.y = 0 if pos.y < 0
    pos

  hider: -> @$el.css visibility: 'hidden'

class MegaballWeb.Views.ScalablePopupView extends MegaballWeb.Views.PopupView
  template: _.template $("#scalable_popup_template").html()
  render_params: {
    heading: false }

  render: ->
    super
    @$el.addClass @style if @style?

class MegaballWeb.Views.InstallUnityView extends MegaballWeb.Views.PopupView
  template: _.template $("#install_unity_popup_template").html()

class MegaballWeb.Views.StatisticsView extends MegaballWeb.Views.ScalablePopupView
  stat_template: $("#statistics_template").html()
  entry_template: _.template "<div class='label'>{{=label}}</div><div>{{=value}}</div>"

  initialize: ->
    @entries = @options.entries ? []
    @user    = @options.user
    @title   = @options.title ? ''
    @club_short_name = ''
    
    @options.buttons = ['close']
    @options.text = @stat_template

    @from_user @user if @user?
    super @options

  render: ->
    super
    @silent_render()

  silent_render: ->
    if @club_short_name? then @$el.find('.stat-club-short-name').html('[<b>'+@club_short_name+'</b>]')
    if @user.provider_info()? then @$el.find('.stat-user-name').html(@title).attr('href', @user.provider_info().link)
    else @$el.find('.stat-user-name').html(@title).attr('href','#')
    @$el.find('.data').html('').append(@render_entries())
    @userpic = new MegaballWeb.Views.UserPictureView el: @$el.find('.userpic')
    @userpic.from_user @user

  render_entries: ->
    _.reduce(
      (@entry_template entry for entry in @entries),
      (x, y) -> x + y,
      "")

  from_user: (user) ->
    @title = user.get 'name'

  from_statistics: (statistics) ->
    match_count = statistics.get('wins') + statistics.get('fails') + statistics.get('draws')
    perc = (x) -> Math.floor(100 * statistics.get(x) / match_count)
    disp = (x) -> if isNaN(x) then '' else "(#{x}%)"
    @club_short_name = statistics.get 'club_short_name'
    @entries = [
      { label: 'уровень', value: statistics.get_level() }
      { label: 'рейтинг', value: statistics.get 'rating' }
      { label: 'побед', value: "#{statistics.get 'wins'} #{disp perc 'wins'}" }
      { label: 'поражений', value: "#{statistics.get 'fails'} #{disp perc 'fails'}" }
      { label: 'сыграно матчей', value: statistics.get('played_fast_matches') ? 0 }
      { label: 'голов забито', value: statistics.get('goals') ? 0 }
      { label: 'спасений ворот', value: statistics.get('gate_saves') ? 0 }
      { label: 'уходов с поля', value: ((statistics.get('played_fast_matches') ? 0) - statistics.get('ended_fast_matches') ? 0)}
    ]

  request_and_show: (@user) ->
    statistics = new MegaballWeb.Models.Statistics user.get '_id'
    statistics.on 'sync', (model) =>
      @from_statistics model
      @silent_render()
    statistics.fetch()
    @show()
