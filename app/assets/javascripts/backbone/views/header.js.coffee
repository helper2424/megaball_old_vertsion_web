class MegaballWeb.Views.HeaderView extends MegaballWeb.Views.MasterView

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

  initialize: ->

    @current_user = @options.current_user
    @router = @options.router

    # views
    @experience = new MegaballWeb.Views.ProgressBarView el: $(".experience-bar")
    @energy     = new MegaballWeb.Views.ProgressBarView el: $(".energy-bar"), style: 'green'
    @vip        = $(".vip")
    @vip.click  => @router.navigate '/store/bottles', true
    @current_user.on 'sync', @context @render
    @lock_on_group = $('.group-lock')

    window.u_events.on 'group_lock', @context @group_lock
  
  #
  # Renderers

  render: ->
    @render_vip()
    @render_user()

  # Fills all fields related to current user
  # such as name, place, rating, picture, etc.
  render_user: ->
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

  # When user joined or created group
  group_lock: (lock) ->
    if lock == "True" then @lock_on_group.addClass('inactive')
    else @lock_on_group.removeClass('inactive')

