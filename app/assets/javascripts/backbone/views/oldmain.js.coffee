class MegaballWeb.Views.OldMainView extends MegaballWeb.Views.MasterView
  el: "#main_block"

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

  weapon_count: 2

  experience_el:     $ '.experience-bar'
  energy_el:         $ '.energy-bar'
  play_button_el:    $ '.main .play-button.button:not(.inactive)'
  user_pic:          $ '.user-picture'
  filter_match_type: $ '.main .filters .match-type'
  filter_count:      $ '.main .filters .count'
  vip:               $ '.vip'

  events:
    'click .play-button.button:not(.inactive)':'quick_play'
    'click .play-button.button.inactive':'quick_play_ingroup'

  initialize: (@current_user, @game_plays, @router)->
    super
    console.log("Initialization Main view")

    window.u_server_error = @context @on_server_error

    @enough_energy = true

    @weapons = @$el.find '.cell.skills'
    @rating = @$el.find '.rating'
    @place = @$el.find '.place'
    $('.vip').click => @router.navigate '/store/bottles', true

    @$el.find('.button.play-button').attr("data-hint", """
    Играть Рейтинговую игру!<br/>
За неё вы получите Опыт, Очки рейтинга, Монеты и Предметы коллекции. За каждую игру тратится #{window.user_default.energy_for_play} энергии.""")

    @filter_match_type  = new MegaballWeb.Views.SelectorView el: @filter_match_type
    @filter_count       = new MegaballWeb.Views.SelectorView el: @filter_count
    @experience_el      = new MegaballWeb.Views.ProgressBarView el: @experience_el
    @energy_el          = new MegaballWeb.Views.ProgressBarView el: @energy_el, style: 'green'
    @user_pic           = new MegaballWeb.Views.UserPictureView el: @$el.find(".picture")

    @username = new MegaballWeb.Views.NameEditorView el: @$el.find(".username")
    @username.set_user @current_user

    @current_user.on 'sync', @context @render_current_user
    @render_current_user()
    @game_plays.on 'sync', @context @render_game_plays
    @game_plays.fetch()

    if window.init_groups
      @group_view = new MegaballWeb.Views.GroupView @router
      @group_view.current_user = @current_user

  quick_play: ->
    if ! @play_clicked
      MegaballWeb.Views.PopupView.loading_show()
      @play_clicked = true
      @current_user.save {
          game_filters: {
            name: 'Quicks Match'
            type: 1
            game_play: @filter_match_type.value()
            max_players: @filter_count.value()
          }
        },
        error: =>
          MegaballWeb.Views.PopupView.loading_hide()
          MegaballWeb.Views.PopupView.alert 'Опаньки! Попробуйте позже :('
          @play_clicked = false
        success: =>
          MegaballWeb.Views.PopupView.loading_hide()
          @router.navigate('play', true)
          @play_clicked = false
        patch: true


  render_current_user: ->

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

    @experience_el.text @experience_text(level: @current_user.get_level())
    $(".experience-hint").attr 'data-hint', @experience_hint_tpl {
      value: @current_user.get('experience')
      bound: @current_user.get_level_bound()
    }
    @experience_el.animate_value @current_user.get_current_exp_level()

    $(".energy-hint").attr 'data-hint', @energy_hint_tpl {
      value: @current_user.get 'energy_restore_factor'
    }
    @energy_el.text @energy_text energy: @current_user.get('energy'), energy_max: @current_user.get('energy_max')
    @energy_el.animate_value Math.round(100 * @current_user.get('energy') / @current_user.get('energy_max'))

    @rating.text @current_user.get 'rating'
    @place.text @current_user.get 'place'
    @user_pic.from_user @current_user
    @render_weapons @current_user.get 'weapons'

    if @current_user.get('energy') <= 0 then @play_button_el.addClass 'inactive'
    else
      @play_button_el.removeClass 'inactive'
      @group_view.render_locks() if @group_view?

    window.u_sound_unity @current_user.get 'sound_on'
    window.u_music_unity @current_user.get 'music_on'

  render_weapons: (weapons) ->
    return unless weapons?

    weapons = _.filter(weapons, (x) -> (not x.type? or x.type == 0) and x.active)
    @weapons.html ''
    for i in [0..@weapon_count]
      div = $ '<div/>'
      weapon = weapons[i]
      new MegaballWeb.Views.SkillView {
        el: div
        model: weapon
      }
      @weapons.append div

  render_game_plays: ->
    console.log 'Render game plays'
    @filter_match_type.selected = (x) =>
      @render_count(x, @filter_count.value())
    options = @game_plays.to_dict()
    options['0'] = 'любой'
    @filter_match_type.set_items options, '0'
    @render_count()

  render_count: (id, tryset) ->
    model = @game_plays.get(id)
    out = {}
    bound = 6
    bound = model.get('max_players') if model?
    for i in [2..bound] by 2
      c = i / 2
      out[i] = "#{c} x #{c}"
    out[0] = 'любое'
    @filter_count.set_items out, '0'
    @filter_count.select tryset if tryset?

  on_server_error: (error, error_msg) ->
    console.log 'Server Error!', error, error_msg
    switch error
      when 'NO_NON_EMPTY_ROOMS' then message = 'Нет комнат в режиме ожидания. Попробуйте позже.'
      when 'NO_FREE_ROOMS' then message = 'Нет свободных комнат для быстрой игры. Попробуйте позже.'
      when 'NO_MORE_SLOTS' then message = 'Нет слота для создания игры. Попробуйте позже.'
      when 'ROOM_IS_FULL' then message = 'Комната переполнена. Попробуйте позже.'
      when 'NO_ENERGY' then message = 'Недостаточно энергии. Попробуйте позже.'
      when 'IN_TRAIN_ALREADY' then message = error_msg
      when 'IN_QUICK_ALREADY' then message = error_msg
      when 'SERVER_REBOOT' then message = 'Сервер будет перезагружен.<br>Зайдите в <a href="http://vk.com/megaball_official" target="_top">группу</a> за подробностями'
      else message = "Опаньки! Ошибка на сервере. Попробуйте позже.<br>#{error_msg}"
    MegaballWeb.Views.PopupView.alert message

  quick_play_ingroup: ->
    MegaballWeb.Views.PopupView.alert """
      Дождитесь пока лидер группы нажмет "играть"
    """

