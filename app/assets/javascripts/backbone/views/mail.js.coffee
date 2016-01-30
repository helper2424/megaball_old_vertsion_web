class MegaballWeb.Views.MailEntry extends MegaballWeb.Views.MasterView
  template: _.template $("#mail_entry_template").html()
  link_template: "<a href='#'>Показать</a>"

  type_mapping:
    'announcement': -> {
      icon: undefined
      data: @model.get('message').replace('\n', '<br/>')
    }

    'changelog': -> {
      icon: undefined
      data: @model.get('message').replace('\n', '<br/>')
    }

    'levelup': -> {
      icon: undefined
      data: "Ваш уровень повысился: #{@model.get('message')}!"
    }

    'collection_complete': -> {
      icon: undefined
      data: "Собрана коллекция: #{@model.get('message')}. Поздравляем!"
      route: '/progress/collections'
    }

    'collection': -> {
      icon: undefined
      data: "Получен коллекционный предмет: #{@model.get('message')}!"
      route: '/progress/collections'
    }

    'achievement': -> {
      icon: undefined
      data: "Получено достижение: #{@model.get('message')}!"
      route: "/progress/achievements/#{@model.get 'message'}"
    }

    'energy_help': -> {
      icon: undefined
      data: "Вы получили #{window.user_default.energy_per_friend} энергии за приглашение #{@model.get('message')}."
    }

    'club_rejected': -> {
      icon: undefined
      data: "Вашу заявку в клуб #{@model.get('message')} отклонили."
    }

    'club_accepted': -> {
      icon: undefined
      data: "Вас приняли в клуб #{@model.get('message')}!"
      route: "/club"
    }

    'warning': -> {
      icon: undefined
      data: @model.get('message').replace('\n', '<br/>')
    }

    'error': -> {
      icon: undefined
      data: @model.get('message').replace('\n', '<br/>')
    }

  initialize: ->
    @model = @options.model
    @render()

  render: ->
    data = _.extend @type_mapping[@model.get 'type'].apply(@), {
      date: @model.get('date').replace(/[tz]/gi, ' ')
    }
    @$el = $ @template data
    if data.route?
      el = $ @link_template
      el.click => @trigger 'goto', data.route
      @$el.find('.after-data').append el

  remove: ->
    @$el.remove()

class MegaballWeb.Views.MailView extends MegaballWeb.Views.MasterView
  el: "#mail_block"

  template: _.template """
    <div class='messages'></div>
    <div class='next-holder'>
      <button class='more'>загрузить еще</button>
    </div>
  """

  events:
    'click .close':'close'
    'click .next':'fetch_next'

  initialize: (@refresh) ->
    super
    console.log("Initialization Mail view")

    @messages = new MegaballWeb.Collections.Messages
    @messages.on 'sync', @context @render
    @refresh.on 'sync', @context @fetch_new

    @list = new MegaballWeb.Views.ScrollView el: @$el.find('.list')
    @list.$().html @template()
    @messages_el = @list.$().find('.messages')
    @views = {}

  navigated_modal: ->
    @render()
    @mark_read_from @upper
    @set_unread 0

  render: ->
    return if @messages.size() == 0

    # Set bounds
    @upper = @messages.bound 'max'
    @lower = @messages.bound 'min'
  
    # Map to views
    _.extend @views, _.object @messages.map (model) =>
      view = new MegaballWeb.Views.MailEntry(model: model)
      view.on 'goto', @context @goto
      [model.get('_id'), view]

    # Calculate unread
    @set_unread _.filter(@views, (x) -> !x.model.get 'read').length

    # Sort by id DESC
    views = _.sortBy(@views, (x) => x.model.get '_id').reverse()

    # Render
    @messages_el.html ''
    @messages_el.append view.$el for id, view of views
    @list.redraw() # redraw scroll position

  fetch_new: ->
    if @upper?
      @messages.fetch_offset @upper, 'gt'
    else
      @messages.fetch()

  fetch_next: ->
    if @lower?
      @messages.fetch_offset @lower, 'lt'

  set_unread: (unread) ->
    window.main_tabs.views['mail'].set_count unread

  mark_read_from: (upper) ->
    $.post "/user/read_message/#{upper}" if upper?

  close: -> @goto()
  goto: (route) ->
    @mark_read_from @upper
    @set_unread 0
    @hide_modal(route)
