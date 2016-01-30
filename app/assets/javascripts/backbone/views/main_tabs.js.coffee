class MegaballWeb.Views.TabView extends MegaballWeb.Views.MasterView
  template: _.template $("#tab_template").html()
  button_template: _.template "<input type='button' class='{{=autocontent}}' />"

  events:
    'click':'click'

  initialize: ->
    @route = @options.route ? ""
    @text = @options.text ? ""
    @count = @options.count ? 0
    @autocontent = @options.autocontent

    @render()

    @counter = @$el.find('.counter')
    @set_count @count

  render: ->
    html = @text
    html += @button_template autocontent: @autocontent if @autocontent?
    @$el.html @template title: html

  set_count: (x) ->
    if not x? or Number(x) == 0
      @counter.hide()
    else
      @counter.show()
      @counter.html x
  
  click: ->
    return if @$el.hasClass 'inactive'
    @trigger 'click', @route


class MegaballWeb.Views.MainTabs extends MegaballWeb.Views.MasterView

  initialize: ->
    super
    console.log("Initialization Main tabs view")
    @views = {}
    @render()

  render: ->
    console.log("Render Main tabs view")
    context = @
    @$el.find('.tab').each ->
      view = new MegaballWeb.Views.TabView {
        el: $(@)
        text: $(@).html()
        route: $(@).attr 'data-route'
        autocontent: $(@).attr 'data-autocontent'
        count: $(@).attr 'data-counter'
      }
      view.on 'click', context.context(context.set_current)
      context.views[view.route] = view

  set_current: (route) ->
    @trigger 'navigate', route
    @activate route

  activate: (route) ->
    @$el.find('.tab').removeClass 'active'
    if @views[route]?
      @views[route].$el.addClass 'active'
