class MegaballWeb.Views.SelectorView extends MegaballWeb.Views.MasterView
  tagName: 'div'
  template: _.template $('#selector_template').html()

  events:
    'click .right':'right'
    'click .left':'left'

  initialize: ->
    super
    @callback = @options.callback ? (->)
    @set_items @options.items, @options.default_value
    @render()

  set_items: (items, select) ->
    @items = items
    @items = {} unless @items?
    @keys = (k for k, v of @items)
    @selected_index = 0
    select = @selected_index unless select?
    @select select
    @callback @value()

  render: ->
    data = @template item: @text()
    @$el.html data

  left: ->
    if @selected_index <= 0 then @selected_index = @keys.length - 1
    else --@selected_index
    @selected @value() if @selected?
    @render()
    @callback @value()

  right: ->
    if @selected_index >= @keys.length - 1 then @selected_index = 0
    else ++@selected_index
    @selected @value() if @selected?
    @render()
    @callback @value()

  select: (val) ->
    @selected_index = i for i, v of @keys when v == val
    @render()

  select_last: ->
    @select @keys[@keys.length - 1]
    @callback @value()

  value: -> @keys[@selected_index]
  text: -> @items[@value()]
