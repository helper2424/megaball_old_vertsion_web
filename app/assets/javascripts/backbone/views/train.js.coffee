class MegaballWeb.Views.TrainRoomView extends MegaballWeb.Views.MasterView
  template: _.template $("#room_template").html()

  events:
    'click':'click'
    'dblclick':'dblclick'

  initialize: ->
    @model = @options.model
    @render()

  render: ->
    @$el = $ @template @model.toJSON()

  click: ->
    @trigger 'click', @model
    @$el.addClass 'active'

  dblclick: ->
    @trigger 'dblclick', @model

class MegaballWeb.Views.TrainView extends MegaballWeb.Views.MasterView
  el: "#train_block"
  room_template: _.template $('#room_template').html()

  table_body_el: $ '.train .table-body'
  connect_to_room_el: $ '.train .connect-to-room'
  create_room_el: $ '.train .create-room'

  filter_title: $ '.train .filters .title'
  filter_match_type: $ '.train .filters .match-type'
  filter_count: $ '.train .filters .count'
  filter_level_from: $ '.train .filters .level-from'
  filter_level_to: $ '.train .filters .level-to'
  filter_password: $ '.train .filters .password'

  events:
    'click .train .update-list':'update_list'
    'click .train .create-room':'create_room'
    'click .train .connect-to-room:not(.inactive)':'connect_to_room'
    'click .table-header .header':'sort_handler'
    'click .select-room':'select_room'

  sort_desc: true

  initialize: (@current_user, @game_plays) ->
    super
    console.log("Initialization Train view")
    @rooms = new MegaballWeb.Collections.RoomsCollection
    @rooms.on 'sync', @context @render
    @game_plays.on 'sync', @context @render_game_plays

    @table_body_el = new MegaballWeb.Views.ScrollView el: @table_body_el
    @filter_title = new MegaballWeb.Views.TexteditView el: @filter_title
    @filter_match_type = new MegaballWeb.Views.SelectorView el: @filter_match_type
    @filter_count = new MegaballWeb.Views.SelectorView el: @filter_count
    @filter_password = new MegaballWeb.Views.TexteditView el: @filter_password

    @filter_level_from = new MegaballWeb.Views.SelectorView el: @filter_level_from, items: window.megaball_config.levels
    @filter_level_to = new MegaballWeb.Views.SelectorView
      el: @filter_level_to
      items: window.megaball_config.levels
      callback: @context (item) ->
        current = @filter_level_from.value()
        items = _.object([i, "#{i}"] for i in [1..Number(item)])
        @filter_level_from.set_items items
        @filter_level_from.select current if items[current]?
    @filter_level_to.select_last()

    @filter_title.$().keypress @context @validate

    @game_plays.fetch()
    @rooms.fetch()
    @validate()

  render: ->
    console.log("Render Train view")
    @visual_rooms = @rooms.to_visual_rooms @game_plays
    @render_list()
    @connect_to_room_el.addClass 'inactive'

  navigated: ->
    @update_list()

  render_list: ->
    @table_body_el.html ''
    @visual_rooms.each (model) =>
      view = new MegaballWeb.Views.TrainRoomView model: model
      view.on 'click', @context @activate_row
      view.on 'dblclick', @context @connect_to_room
      @table_body_el.$().append view.$el

  validate: ->
    valid = @filter_title.value().length > 0
    if valid then @create_room_el.removeClass 'inactive'
    else @create_room_el.addClass 'inactive'

  sort_handler: (event) ->
    el = $ event.currentTarget
    window.u_play_sound 0
    @sort_desc = not @sort_desc
    @visual_rooms.change_sort el.attr 'data-sort-field'
    @visual_rooms.sort()
    @visual_rooms.models.reverse() if @sort_desc
    @render_list()

  activate_row: (model) ->
    @table_body_el.$el.find('.tr').removeClass('active')
    @connect_to_room_el.removeClass 'inactive'
    @current_room = model

  update_list: ->
    @rooms.fetch()

  render_game_plays: ->
    console.log 'Render game plays'
    @filter_match_type.selected = _.bind @render_count, @
    @filter_match_type.set_items @game_plays.to_dict()
    @render_count @filter_match_type.value()

  render_count: (id) ->
    model = @game_plays.get(id).attributes
    out = {}
    for i in [2..model.max_players] by 2
      c = i / 2
      out[i] = "#{c} x #{c}"
    @filter_count.set_items out
    @filter_count.select_last()

  create_room: ->
    @current_user.save {
        game_filters: {
          type: 2
          name: @filter_title.value()
          game_play: @filter_match_type.value()
          max_players: Number(@filter_count.value())
          level_from: Number(@filter_level_from.value())
          level_to: Number(@filter_level_to.value())
          password: @filter_password.value()
          allow_skills: 'true'
          allow_spectators: 'true'
        }
      },
      error: (model, respond) => @render_validation_errors jQuery.parseJSON respond.responseText
      success: => @router.navigate 'play', true
      patch: true

  render_validation_errors: (params) ->
    if params.name?
      MegaballWeb.Views.PopupView.alert "Название комнаты должно содержать от 3 до 25 символов!"
    else if params.level_from?
      MegaballWeb.Views.PopupView.alert '"Уровень с" не может быть больше "по"!'
    else
      MegaballWeb.Views.PopupView.alert 'Опаньки! Ошибка на сервере. Перезагрузите страницу.'

  connect_to_room: ->
    if @current_room.get('lock')
      MegaballWeb.Views.PopupView.prompt
        text: "Введите пароль:"
        password: true
        ok: @context (pass) ->
          @pass = pass
          @check_password @pass if @pass != ""
    else
      @pass = ''
      @save_room_to_user()


  check_password: (pass) ->
    check_password = new MegaballWeb.Models.CheckPassword
    check_password.on 'sync', @context (model) ->
      if model.get('correct') == true
        @save_room_to_user()
      else
        MegaballWeb.Views.PopupView.alert "Неправильный пароль!"
    check_password.fetch data: id: @current_room.get('_id'), password: pass

  save_room_to_user: (room) ->
    @current_user.save {
        game_type: 2
        server: "#{@current_room.get 'server_host'}:#{@current_room.get 'server_port'}"
        playing_room: @current_room.get '_id'
        password: @pass ? ''
      },
      error: @context -> return
      success: => @router.navigate 'play', true
      patch: true
