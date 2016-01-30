class MegaballWeb.Views.FastMatchesView extends MegaballWeb.Views.MasterView

  css_class: 'matches'
  experience_text: _.template '<span class="big">уровень:</span> {{=level}}'
  energy_text: _.template '{{=energy}} / {{=energy_max}}'
  mul_text: _.template ' <span class="mul">(x{{=value}})</span>'

  experience_hint_tpl: _.template """
    <b>{{=value}}/{{=bound}}</b><br/> 
    Играйте рейтинговые матчи, чтобы набирать опыт.
  """

  energy_hint_tpl: _.template """
    За минуту восстановится {{=value}} пунктов энергии.
  """

  events:
    'click .do-refresh':'do_refresh'
    'click .do-play:not(.inactive)':'do_play'
    'click .do-play.inactive':'do_play_inactive'

  initialize: ->

    @current_user = @options.current_user
    @game_plays = @options.game_plays
    @router = @options.router

    # models
    @rooms = new MegaballWeb.Collections.RoomsCollection
    @rooms.set_type "fast"

    # views
    @tabs       = new MegaballWeb.Views.MainTabs        el: @$el.find('.tabs')
    @matches    = new MegaballWeb.Views.ScrollView      el: @$el.find('.match-list')
    @match_type = new MegaballWeb.Views.SelectorView    el: @$el.find('.match-type')
    @username   = new MegaballWeb.Views.NameEditorView  el: @$el.find(".username")
    @userpic    = new MegaballWeb.Views.UserPictureView el: @$el.find(".userpic")
    @experience = new MegaballWeb.Views.ProgressBarView el: $(".experience-bar")
    @energy     = new MegaballWeb.Views.ProgressBarView el: $(".energy-bar"), style: 'green'
    @place      = @$el.find(".place")
    @rating     = @$el.find(".rating")
    @vip        = $(".vip")
    @vip.click  => @router.navigate '/store/bottles', true

    if window.init_groups
      @group_view = new MegaballWeb.Views.GroupView {
        router: @router
        el: @$el.find('.groups')
      }
      @group_view.current_user = @current_user

    @current_user.on 'sync', @context @render
    @game_plays.on 'sync', @context @render_game_plays
    @rooms.on 'sync', => @render_rooms()

  #
  # Events
  
  do_refresh: -> @rooms.fetch()

  do_play_inactive: -> MegaballWeb.Views.PopupView.alert 'Вы не лидер группы!'

  do_play: ->
    MegaballWeb.Views.PopupView.loading_show()
    @current_user.save {
        game_filters: {
          type: 1
          name: 'fast match'
          game_play: @match_type.value()
        }
      },
      error: =>
        MegaballWeb.Views.PopupView.loading_hide()
        MegaballWeb.Views.PopupView.alert 'Опаньки! Попробуйте позже :('
      success: =>
        MegaballWeb.Views.PopupView.loading_hide()
        @router.navigate('play', true)
      patch: true
  
  #
  # Renderers

  render: ->
    @render_vip()
    @render_user()
    @render_game_plays()

  navigated: ->
    @rooms.fetch()

  render_game_plays: ->
    @scope = undefined
    options = @game_plays.to_dict()
    options['any'] = 'любой'
    @match_type.selected = (x) =>
      if x == "any" then @scope = undefined
      else @scope = { game_play: Number x }
      @render_rooms()
    @match_type.set_items options, 'any'
    @render_rooms()

  # Creates match entries and puts them
  # to @matches
  render_rooms: ->
    el = @matches.$()
    el.html ''
    return if @rooms.size() == 0
    game_plays = @game_plays.to_dict()
    rooms = @rooms
    rooms = _(rooms.where @scope) if @scope?
    rooms.each (room) =>
      view = new MegaballWeb.Views.MatchEntryView {
        model: room
        game_plays: game_plays
      }
      el.append view.$el

  # Fills all fields related to current user
  # such as name, place, rating, picture, etc.
  render_user: ->
    @username.set_user @current_user
    @place.html @current_user.get 'place'
    @rating.html @current_user.get 'rating'
    @userpic.from_user @current_user

    @experience.text @experience_text(level: @current_user.get_level())
    @experience.animate_value @current_user.get_current_exp_level()
    $(".experience-hint").attr 'data-hint', @experience_hint_tpl {
      value: @current_user.get('experience')
      bound: @current_user.get_level_bound()
    }

    @energy.text @energy_text energy: @current_user.get('energy'), energy_max: @current_user.get('energy_max')
    @energy.animate_value Math.round(100 * @current_user.get('energy') / @current_user.get('energy_max'))
    $(".energy-hint").attr 'data-hint', @energy_hint_tpl {
      value: @current_user.get 'energy_restore_factor'
    }

  # Lights vip based on light_vip in user_weapon.
  # Also calculates multiplication rate for vip
  # and puts it to hint
  render_vip: ->
    vips = _.filter(@current_user.get('weapons'), (x) -> x.light_vip)
    light_vip = vips.length > 0

    if light_vip
      millis = new Date().getTime()
      left =
        _.max(
          _.map(
            vips,
            (x) -> x.charge * x.action_time - (millis - x.activate_time  * 1000)))
      light_vip = left > 0

    if light_vip
      speed =
        Math.round((_.foldl(
          _.map(vips, (x) -> (x.mul_params.experience ? 0)),
          ((r, x) -> r + x),
          0) - 1) * 100)
      @vip.addClass 'active'
      @vip.attr('data-hint',
        """VIP статус активен. 
        Скорость прокачки увеличена на #{speed}%.<br/>
        Энергии тратится в 2 раза меньше.<br/>
        Все характеристики +1.<br/>
        <span style='color: #833'>Оставшееся время: #{left.format_date_from_millis()}</span>""")
    else
      @vip.removeClass 'active'
      @vip.attr('data-hint',
        'Покупайте VIP статус для быстрой прокачки и улучшения характеристик!')

