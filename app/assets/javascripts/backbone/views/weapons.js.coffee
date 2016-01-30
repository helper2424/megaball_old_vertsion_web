class MegaballWeb.Views.WeaponView extends MegaballWeb.Views.MasterView
  tagName: 'div'
  template: _.template $('#weapon_template').html()

  events:
    'click':'invoke_handler'
    'mouseenter':'hover'
    'mouseleave':'blur'

  initialize: ->
    super
    @model = @options.model
    @handler = @options.handler ? (->)
    @hover_handler = @options.hover_handler ? (->)
    @blur_handler = @options.blur_handler ? (->)
    @render()

  render: ->
    @$el = $ @template _.extend @model, {
      display_charge: @model.wasting
    }
    if @model.description?
      @$el.addClass 'has-hint'
      description = @model.description
      if @model.type == 0 # skill # ToDo make constant, lazy bitch
        description += "<br/>Осталось зарядов: #{@model.charge}"
      @$el.attr 'data-hint', description

  invoke_handler: -> @handler @model
  hover: -> @hover_handler @model
  blur: -> @blur_handler @model

class MegaballWeb.Views.WeaponsView extends MegaballWeb.Views.MasterView
  tagName: 'div'
  template: _.template $('#weapon_template').html()
  elements_per_page: 8

  initialize: ->
    super
    console.log("Initialization weapons view")
    @page = 0
    @left_el = @options.left_el
    @right_el = @options.right_el
    @left_el.click @context @prev_page
    @right_el.click @context @next_page
    @filter = @options.filter ? (-> true)
    @handler = @options.handler ? (->)
    @hover_handler = @options.hover_handler ? (->)
    @blur_handler = @options.blur_handler ? (->)

  render: ->
    return unless @items?
    skip = @elements_per_page * @page
    count = 0
    temp = $ '<div/>'
    for item in @items
      continue if skip-- > 0
      break if count++ >= @elements_per_page
      view = new MegaballWeb.Views.WeaponView
        model: item
        handler: @handler
        hover_handler: @hover_handler
        blur_handler: @blur_handler
      temp.append view.$el

    @$el.html ''
    @$el.append temp

    if @is_last_page() then @right_el.addClass 'inactive'
    else @right_el.removeClass 'inactive'

    if @is_first_page() then @left_el.addClass 'inactive'
    else @left_el.removeClass 'inactive'

  next_page: ->
    console.log @
    if not @is_last_page()
      ++@page
      @render()

  prev_page: ->
    if not @is_first_page()
      --@page
      @render()

  is_last_page: -> @items.length <= @elements_per_page * (@page + 1)
  is_first_page: -> @page <= 0

  set_items: (items) ->
    @items = _.filter(items, @filter)
    @reset if @items.length != @length
    @length = @items.length
    @render()

  reset: ->
    @page = 0

