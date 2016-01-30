class MegaballWeb.Views.AchievementEntryView extends MegaballWeb.Views.MasterView
  template: _.template $("#achievement_template").html()
  item: _.template "<li>{{=data}}</li>"

  labelvalue: _.template """
    <span class='label'>{{=label}}</span>
    <span class='value'>{{=value}}</span>
  """

  events:
    'mouseenter .data':'show_description'
    'mouseleave .data':'hide_description'
    'mousemove':'move'

  stage_color: (stage) -> switch stage
    when 0 then 'green'
    when 1 then ''
    else 'red'

  params_mapping:
    'best_player': (item) -> @labelvalue {
      label: "Лучший игрок"
      value: "#{@statistics.get("best_player") ? 0} / #{item}"
    }

    'wins': (item) -> @labelvalue {
      label: "Победы"
      value: "#{@statistics.get("wins") ? 0} / #{item}"
    }

    'goals': (item) -> @labelvalue {
      label: "Голы"
      value: "#{@statistics.get("goals") ? 0} / #{item}"
    }

    'goal_passes': (item) -> @labelvalue {
      label: "Голевые пасы"
      value: "#{@statistics.get("goal_passes") ? 0} / #{item}"
    }

    'collections_done': (item) -> @labelvalue {
      label: "Собрано коллекций"
      value: "#{@statistics.get("collections_done") ? 0} / #{item}"
    }

    'friends_count': (item) -> @labelvalue {
      label: "Друзей"
      value: "#{@statistics.get("friends_count") ? 0} / #{item}"
    }

    'coins': (item) -> @labelvalue {
      label: "Монеты"
      value: "#{@statistics.get("coins") ? 0} / #{item}"
    }

    'played_in_group': (item) -> @labelvalue {
      label: "Игры в группе"
      value: "#{@statistics.get("played_in_group") ? 0} / #{item}"
    }

    'rod_hits': (item) -> @labelvalue {
      label: "Попадания в штангу"
      value: "#{@statistics.get("rod_hits") ? 0} / #{item}"
    }

    'skill_usage.teleport_self': (item) -> @labelvalue {
      label: "Телепортации"
      value: "#{@statistics.get('skill_usage')?.teleport_self ? 0} / #{item}"
    }

    'skill_usage.push_players': (item) -> @labelvalue {
      label: "Использовано толчков"
      value: "#{@statistics.get('skill_usage')?.push_players ? 0} / #{item}"
    }

    'skill_usage.slowdown_players': (item) -> @labelvalue {
      label: "Замедленно"
      value: "#{@statistics.get('skill_usage')?.slowdown_players ? 0} / #{item}"
    }

    'skill_usage.pull_balls': (item) -> @labelvalue {
      label: "Использовано"
      value: "#{@statistics.get('skill_usage')?.pull_balls ? 0} / #{item}"
    }

    'dynamic_stats.wins_with_3_goals_delta': (item) -> @labelvalue {
      label: "Матчи"
      value: "#{@statistics.get('dynamic_stats')?.wins_with_3_goals_delta ? 0} / #{item}"
    }

    'dynamic_stats.played_trainings_10m': (item) -> @labelvalue {
      label: "Комнат"
      value: "#{@statistics.get('dynamic_stats')?.played_trainings_10m ? 0} / #{item}"
    }

    'dynamic_stats.max_fast_matches_per_day': (item) -> @labelvalue {
      label: "Матчей в день"
      value: "#{@statistics.get('dynamic_stats')?.max_fast_matches_per_day ? 0} / #{item}"
    }

    'dynamic_stats.auto_goals': (item) -> @labelvalue {
      label: "Автоголов"
      value: "#{@statistics.get('dynamic_stats')?.auto_goals ? 0} / #{item}"
    }

    'dynamic_stats.bought_faces': (item) -> @labelvalue {
      label: "Куплено лиц"
      value: "#{@statistics.get('dynamic_stats')?.bought_faces ? 0} / #{item}"
    }

    'distance_walked': (item) -> @labelvalue {
      label: "Расстояние"
      value: "#{Math.round(@statistics.get('distance_walked')).format_with_k() ? 0} / #{item.format_with_k()}"
    }

  prise_mapping:
    'experience': (item) -> @labelvalue {
      label: 'Опыт'
      value: item
    }

    'coins': (item) -> @labelvalue {
      label: 'Монеты'
      value: "<input type='button' class='icon price-coin-big-icon' value='#{item}' />"
    }

    'stars': (item) -> @labelvalue {
      label: 'Звезды'
      value: "<input type='button' class='icon price-star-big-icon' value='#{item}' />"
    }

    'rating': (item) -> @labelvalue {
      label: 'Очки рейтинга'
      value: item
    }

  initialize: ->
    @current_user = @options.user
    @statistics = @options.statistics
    @model = @options.model
    @render()

  render: ->

    @$el = $ @template {
      title: @model.get 'title'
      picture: @model.get 'picture'
      description: @model.get 'description'
      achieved: @model.get 'achieved'
    }

    @progress = new MegaballWeb.Views.ProgressBarView {
      el: @$el.find('.progress')
      style: "small #{@stage_color @model.get 'stage'}"
      auto_color: true
    }
    @progress.set_value(if @model.get('achieved') then 100 else @model.get('status') ? 0)

    @description = @$el.find('.description')
    @prises = @$el.find('.prise').html('')
    @params = @$el.find('.params').html('')

    unless @model.get 'achieved'
      current = @model.get('achievement_entry')[@model.get 'stage']

      for item, value of current.params
        if @params_mapping[item]?
          @params.append @item {
            data: @params_mapping[item].apply(@, [value])
          }

      for item, value of current.prise
        if @prise_mapping[item]?
          @prises.append @item {
            data: @prise_mapping[item].apply(@, [value])
          }

  move: ->
    pos = window.mouse_position

    delta = 60

    if pos.x + @description.width() + delta > $(window).width()
      pos.x -= @description.width() + delta
    if pos.y + @description.height() + delta > $(window).height()
      pos.y -= @description.height() + delta

    @description.css {
      left: "#{pos.x}px"
      top:  "#{pos.y}px"
    }

  show_description: ->
    @description.finish().fadeIn('fast')

  hide_description: ->
    @description.finish().fadeOut('fast')

class MegaballWeb.Views.AchievementsView extends MegaballWeb.Views.MasterView

  events:
    'click .store-right:not(.inactive)':'right'
    'click .store-left:not(.inactive)':'left'

  items_per_page: 8

  initialize: ->
    @current_user = @options.user
    @current_user.on 'sync', => @statistics.fetch()

    @statistics = new MegaballWeb.Models.Statistics
    @statistics.on 'sync', => @items.fetch()

    @items = new MegaballWeb.Collections.Achievements
    @items.on 'sync', @context @set_items

    @items_el = @$el.find('.items')
    @left_el = @$el.find('.store-left')
    @right_el = @$el.find('.store-right')

    @current_page = 0

  navigated: (id) ->
    if id?
      @items.once 'sync', =>
        index = undefined
        for i, val of @items.toJSON()
          if val.title == id
            index = i
            break
        if index?
          @current_page = Math.floor(index / @items_per_page)
          @render()
    @statistics.fetch()

  render: ->
    @items_el.html ''

    for item in @items.filter((x, i) => i >= (@current_page * @items_per_page))[0...@items_per_page]
      @items_el.append (new MegaballWeb.Views.AchievementEntryView {
        model: item
        user: @current_user
        statistics: @statistics
      }).$el

    @left_el.removeClass 'inactive'
    @left_el.addClass 'inactive' if @is_first_page()
    @right_el.removeClass 'inactive'
    @right_el.addClass 'inactive' if @is_last_page()

  set_items: (items) ->
    @items = items
    @render()

  is_last_page: -> @items_per_page * (@current_page+1) >= @items.length
  is_first_page: -> @current_page == 0

  right: -> unless @is_last_page()
    @current_page += 1
    @render()

  left: -> unless @is_first_page()
    @current_page -= 1
    @render()
