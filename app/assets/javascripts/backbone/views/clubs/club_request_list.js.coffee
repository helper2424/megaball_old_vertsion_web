#= require ./../popup

class MegaballWeb.Views.ClubRequestListView extends MegaballWeb.Views.ScalablePopupView

  style: 'contrast'
  render_params: {
    heading: 'заявки' }

  initialize: ->
    @requests = new MegaballWeb.Collections.ClubRequests
    @requests.on 'sync', @context @silent_render
    el = $("#club_request_list_template")
    el.find('ul').html("<h1>загрузка списка...</h1>")
    @options.text = el.html()
    @options.buttons = ['close']
    super @options
    @on = MegaballWeb.Views.MasterView::on

  request: ->
    @requests.fetch()

  silent_render: ->
    el = @list.$()
    el.html ''

    @views = @requests.map (x) =>
      view = new MegaballWeb.Views.ClubRequestView model: x
      view.on 'accept_user', (m) => @trigger 'accept_user', m
      view.on 'reject_user', (m) => @trigger 'reject_user', m
      view

    if @views.length == 0
      el.html '<h1>нет новых запросов</h1>'
    else
      el.append v.$el for v in @views
    @list.update()

  set_content: ->
    super
    @list = new MegaballWeb.Views.ScrollView el: @$el.find('ul')

class MegaballWeb.Views.ClubRequestView extends MegaballWeb.Views.MasterView
  template: _.template $("#club_request_template").html()

  events:
    'click .do-show-info':'handle_click'
    'click .accept':'handle_accept'
    'click .reject':'handle_reject'

  initialize: ->
    @model = @options.model
    @render()

  render: ->
    @$el.html @template @model.toJSON()

  handle_click: ->
    stat = new MegaballWeb.Views.StatisticsView user: @model
    stat.request_and_show(@model)

  handle_accept: -> @trigger 'accept_user', @model.toJSON()
  handle_reject: -> @trigger 'reject_user', @model.toJSON()
