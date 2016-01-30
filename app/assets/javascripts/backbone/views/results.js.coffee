class MegaballWeb.Views.ResultStatView extends MegaballWeb.Views.MasterView
  template: _.template $("#result_stat_view_template").html()
  entry_template: _.template $("#result_stat_view_entry_template").html()
  value_template: _.template "+{{=value}}"

  initialize: ->
    @boom = @options.boom ? 'stars'
    @active = @options.active ? true
    @tpl = @options.template ? ((x) -> x)
    @$el = $ @template()
    @data = []

  render: ->
    @$el.html ''
    @shown = undefined

  set_data: (data) ->
    @data = data
    @render()

  hide: -> @$el.hide()

  show: ->
    if @shown? then @finish()
    else @animate()
    @shown = true
    @$el.show()

  animate: ->
    res = 0
    process = (i) =>
      entry = @data[i]
      return @finish() if i >= @data.length

      el = $ @entry_template {
        description: entry.description
        value: 0
      }

      @$el.append el
      @animate_to {
        el: el
        value: entry.value
        callback: => process i+1
        each: (val) =>
          res += val
          @trigger 'value', @tpl val
      }
    process 0

  animate_to: ({el, value, callback, each}) ->
    TIMEOUT=100
    val = el.find('.value')
    temp_value = 0

    temp = =>
      if temp_value >= value
        val.html @value_template value: value
        setTimeout callback, TIMEOUT if callback?
        return
      each temp_value if each?
      val.html @value_template value: temp_value
      temp_value += 1
      setTimeout temp, TIMEOUT
    temp()

  finish: ->
    @trigger 'finish', @tpl @result

  set_active: (flag) ->
    @active = flag
    @trigger 'active', flag

class MegaballWeb.Views.ResultsView extends MegaballWeb.Views.MasterView
  el: "#results_block"
  score_offset: '-115px'
  dot_template: _.template "<button class='button dot'></button>"

  events:
    'click .main-menu':'main_menu'
    'click .again':'again'

  initialize: (@current_user, @results, @refresh) ->
    super

    @title =
      self: @$el.find '.title'
      left: @$el.find '.left'
      right: @$el.find '.right'

    @views =
      experience: new MegaballWeb.Views.ResultStatView {
        boom: 'lightnings'
        template: (x) -> "Опыт: #{x}"
      }
      money: new MegaballWeb.Views.ResultStatView {
        boom: 'money'
        template: (x) -> "Монеты: #{x}"
      }
      rating: new MegaballWeb.Views.ResultStatView {
        boom: 'cups'
        template: (x) -> "Рейтинг: #{x}"
      }
      collections: new MegaballWeb.Views.ResultStatView {
        boom: 'lightnings'
        template: (x) -> "Коллекции: #{x}"
      }
    @view_keys = _.keys @views
    @current_key = 0

    @flow = @$el.find '.flow'
    @boom = @$el.find '.boom'
    @layout = @$el.find '.layout'
    @view = @$el.find '.view'
    @dots = @$el.find '.dots'
    @head = @$el.find '.head'

    that = @
    for key, view of @views
      ((dot) =>
        view.on 'value', (val) => @head.html val
        view.on 'finish', (val) => @head.html val
        view.on 'active', (val) => if val then dot.show() else dot.hide()
        view.hide()
        dot.attr 'data-view', key
        dot.addClass key
        dot.click -> that.show_view $(@).attr 'data-view'
        @dots.append dot
        @view.append view.$el
      )($ @dot_template())

  rotate_views: (name, timeout = 4000) ->
    clearTimeout @timeout_id if @timeout_id?
    @current_key = _.indexOf(@view_keys, name)
    @timeout_id = setTimeout (=>
      @current_key += 1
      @current_key = 0 if @current_key >= @view_keys.length
      @show_view @view_keys[@current_key]
    ), timeout

  navigated: ->
    @render()

  render: ->
    console.log @results.get 'score'
    score = @results.get_score()
    type = @results.get_type()

    @$el.find(".score-#{x.id}").text x.value for x in score

    expmul = _.foldl(
      _.map(
        _.filter(@current_user.get('weapons'),
          (x) -> x.active and x.mul_params.experience?)
        , (x) -> x.mul_params.experience),
      ((x, y) -> x * y),
      1)

    # Experience
    #
    @views.experience.data = []
    @views.experience.data.push {
      value: @results.get_experience_for(type),
      description: @tpl_experience_for(type) }
    @views.experience.data.push {
      value: @results.get('exp_for_goals_delta') ? 0,
      description: 'победа с разницей больше 3 голов' }
    @views.experience.data.push {
      value: @results.get('exp_for_max_goals') ? 0,
      description: 'больше всех голов' }
    @views.experience.data.push {
      value: @results.get('exp_for_max_goal_passes') ? 0,
      description: 'больше всех голевых пасов' }
    @views.experience.data.push {
      value: @results.get('exp_for_max_gate_saves') ? 0,
      description: 'за спасение ворот' }
    @views.experience.data.push {
      value: @results.get('team_mates') ? 0,
      description: 'за каждого друга в группе' }
    @views.experience.result = (if expmul == 1
        @results.get('experience')
      else
        @results.get('experience') +
          "<span class='extra'>" +
          " (+#{(Math.round(expmul * 10000) / 100) - 100}%)</span>")
    @views.experience.render()

    # Money
    #
    @views.money.data = []
    @views.money.data.push {
      value: @results.get_money_for(type),
      description: @tpl_money_for(type) }
    @views.money.result = @results.get('coins')
    @views.money.render()

    # Rating
    #
    @views.rating.data = []
    @views.rating.data.push {
      value: @results.get_rating_for(type),
      description: @tpl_rating_for(type) }
    @views.rating.data.push {
      value: @results.get('team_mates'),
      description: 'за каждого друга в группе' }
    @views.rating.data.push {
      value: 5,
      description: 'лучший игрок матча' } if @results.get('best')
    @views.rating.result = @results.get('rating')
    @views.rating.render()

    # Collections
    #
    coll = @refresh.get('new_collection')
    @views.collections.set_active coll?
    @views.collections.data = []
    @views.collections.data.push {
      value: 1
      description: "Коллекция \"#{coll?.title}\"" }
    @views.collections.result = 1
    @views.collections.render()

    @current_key = 0
    @load_header type, =>
      @show_view @view_keys[0]
      @rotate_views()
  
  load_header: (type='defeat', callback) ->
    @flow.hide()
    @boom.hide()
    @title.self.removeClass @title.class if @title.class?
    @title.self.addClass (@title.class = type)

    value = @title.self.css 'margin-top'
    @title.left.css { opacity: 0, left: 0 }
    @title.right.css { opacity: 0, right: 0 }
    @title.self.css { marginTop: '-100px' }
    @title.self.show()

    @layout.css { opacity: 0, marginTop: '0px' }
    @layout.show()

    @title.self.animate { 'margin-top': '120px' }, 'fast', @context ->
      @title.self.animate { 'margin-top': '80px' }, 'fast', @context ->
        @title.self.animate { 'margin-top': value }, 'fast', @context ->
          @boom.fadeIn 'fast' if @type != 'defeat'
          @layout.fadeIn 'fast'
          @flow.fadeIn 'fast'
          @title.left.animate { opacity: 1, left: @score_offset }
          @title.right.animate { opacity: 1, right: @score_offset }
          @layout.animate { opacity: 1, marginTop: '30px' }, 'fast'
          callback() if callback?

  show_view: (name) ->
    view = @views[name]
    if view.active
      @current_view = name
      @dots.find(".dot").removeClass 'active'
      @dots.find(".dot.#{name}").addClass 'active'
      @$el.find('.entries').hide()
      @render_boom view.boom
      view.show()
      @rotate_views name
    else
      @rotate_views name, 0

  render_boom: (name) ->
    @boom.fadeOut 'fast', @context ->
      @boom.removeClass @boom.toRemove if @boom.toRemove?
      @boom.toRemove = name
      @boom.addClass @boom.toRemove
      @boom.fadeIn 'fast'

  main_menu: -> @router.navigate '/main', true

  again: -> @router.navigate '/play', true

  tpl_experience_for: (type) ->
    switch type
      when 'victory' then 'опыт за победу'
      when 'draw' then 'опыт за ничью'
      when 'defeat' then 'опыт за поражение'

  tpl_money_for: (type) ->
    switch type
      when 'victory' then 'монеты за победу'
      when 'draw' then 'монеты за ничью'
      when 'defeat' then 'монеты за поражение'

  tpl_rating_for: (type) ->
    switch type
      when 'victory' then 'рейтинг за победу'
      when 'draw' then 'рейтинг за ничью'
      when 'defeat' then 'рейтинг за поражение'
