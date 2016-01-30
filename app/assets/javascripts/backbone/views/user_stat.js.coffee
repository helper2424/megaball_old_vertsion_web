class MegaballWeb.Views.UserStatEntryView extends MegaballWeb.Views.MasterView
  template: _.template $("#user_stat_template").html()

  initialize: ->
    @title = @options.title ? ''
    @value = @options.value ? ''
    @render()

  render: ->
    @$el = $ @template {
      title: @title
      value: @value
    }

class MegaballWeb.Views.UserStatView extends MegaballWeb.Views.MasterView

  events:
    'click .store-right:not(.inactive)':'right'
    'click .store-left:not(.inactive)':'left'

  items_per_page: 18

  stats:
    'played_fast_matches': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'сыграно быстрых игр'
        value: @formatValue(@getval('played_fast_matches'))
      }
    'created_rooms': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'создано комнат'
        value: @formatValue(@getval('created_rooms'))

      }
    'played_trainings': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'сыграно тренировок'
        value: @formatValue(@getval('played_trainings'))
      }
    'played_in_group': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'сыграно в группе'
        value: @formatValue(@getval('played_in_group'))
      }
    'distance_walked': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'пройденная дистанция'
        value: @formatValue(@getval('distance_walked'))
      }
    'nitro_used': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'использовано нитро'
        value: @formatValue(@getval('nitro_used'))
      }
    'ball_kicks': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'ударов по мячу'
        value: @formatValue(@getval('ball_kicks'))
      }
    'player_kicks': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'ударов по игрокам'
        value: @formatValue(@getval('player_kicks'))
      }
    'goals': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'голов'
        value: @formatValue(@getval('goals'))
      }
    'goal_passes': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'голевых пасов'
        value: @formatValue(@getval('goal_passes'))
      }
    'rod_hits': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'ударов в штангу'
        value: @formatValue(@getval('rod_hits'))
      }
    'wins': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'побед'
        value: @formatValue(@getval('wins'))
      }
    'best_player': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'лучший игрок'
        value: @formatValue(@getval('best_player'))
      }
    'draws': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'сыграно в ничью'
        value: @formatValue(@getval('draws'))
      }
    'fails': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'поражений'
        value: @formatValue(@getval('fails'))
      }
    'rating': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'рейтинг'
        value: @formatValue(@getval('rating'))
      }
    'friends_count': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'друзей в игре'
        value: @formatValue(@getval('friends_count'))
      }
    'skill_usage.teleport_self': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'телепортов'
        value: @formatValue(@getval('skill_usage.teleport_self'))
      }
    'skill_usage.push_players': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'толчков'
        value: @formatValue(@getval('skill_usage.push_players'))
      }
    'skill_usage.slowdown_players': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'замедленно'
        value: @formatValue(@getval('skill_usage.slowdown_players'))
      }
    'skill_usage.pull_balls': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'притяжений мячей'
        value: @formatValue(@getval('skill_usage.pull_balls'))
      }
    'dynamic_stats.wins_with_3_goals_delta': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'побед больше чем в 3 гола'
        value: @formatValue(@getval('skill_usage.wins_with_3_goals_delta'))
      }
    'dynamic_stats.auto_goals': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'автоголов'
        value: @formatValue(@getval('skill_usage.auto_goals'))
      }
    'dynamic_stats.bought_faces': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'куплено лиц'
        value: @formatValue(@getval('skill_usage.bought_faces'))
      }
    'leaved_fast_matches': ->
      new MegaballWeb.Views.UserStatEntryView {
        title: 'покинуто быстрых игр'
        value: @formatValue(@getval('played_fast_matches') - @getval('ended_fast_matches'))
      }

  initialize: ->
    @current_user = @options.user

    @items_left = @$el.find('.items-left')
    @items_right = @$el.find('.items-right')
    @left_el = @$el.find('.store-left')
    @right_el = @$el.find('.store-right')

    @current_page = 0
    @once 'first', => @first()

  navigated: ->
    @trigger 'first'
    @statistics.fetch()

  first: ->
    @statistics = new MegaballWeb.Models.Statistics
    @statistics.on 'sync', => @update()
    @current_user.on 'statistics', => @statistics.fetch()

  update: ->
    @data = @current_user.toJSON()
    _.extend @data, @statistics.toJSON()
    @views = []
    @clear_el()

    i = 0
    per_column = @items_per_page / 2
    el = @items_right
    for field, x of @stats
      item       = @stats[field].apply @
      continue unless item.value? and item.value != ""
      @views.push item
      if (i % per_column == 0)
        el = if (@items_left == el) then @items_right else @items_left
      item.$el.hide()
      el.append item.$el

      i += 1
    @render()

  render: (speed) ->
    offset = @current_page * @items_per_page

    @$el.find('.item').hide(speed)
    for i in [offset...offset + @items_per_page]
      break if i >= @views.length
      view = @views[i]
      view.$el.show speed

    @left_el.removeClass 'inactive'
    @left_el.addClass 'inactive' if @is_first_page()
    @right_el.removeClass 'inactive'
    @right_el.addClass 'inactive' if @is_last_page()

  is_last_page: -> @items_per_page * (@current_page + 1) >= @views.length
  is_first_page: -> @current_page == 0

  right: -> unless @is_last_page()
    @current_page += 1
    @render('fast')

  left: -> unless @is_first_page()
    @current_page -= 1
    @render('fast')

  getval: (option) ->
    path = option.split '.'
    return null unless path?
    _.foldl path, ((v, x) -> v = v[x]), @data

  clear_el: ->
    @items_left.html ''
    @items_right.html ''


  formatValue: (val) ->
    if isNaN(val) then "" else Math.round(val).format_with_k()
