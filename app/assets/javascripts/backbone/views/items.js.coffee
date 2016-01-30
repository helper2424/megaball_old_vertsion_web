class MegaballWeb.Views.ItemView extends MegaballWeb.Views.MasterView
  tagName: 'div'
  template: _.template $('#item_template').html()

  events:
    'click .action:not(.inactive)':'action'

  initialize: ->
    super
    @router = @options.router ? {}
    @model = @options.model ? {}
    @purchase = new MegaballWeb.Views.PurchaseView
      model: @model
    @purchase.on 'success_buy', => @trigger 'success_buy', @model
    @render()

  render: ->
    data = _.extend @model.toJSON(), {
      reload: _.find(@model.get("item_contents"), (x) -> x.is_charge && x.chargable)?
      lock: MegaballWeb.current_user.get_level() < @model.get('level_min')
    }

    data.coins = window.sub_zero_price_stub if data.coins < 0
    data.stars = window.sub_zero_price_stub if data.stars < 0

    @$el = $ @template data
    @$el.append @purchase.$el
    @$el.addClass 'has-hint'
    @$el.attr 'data-hint', @model.get('description')

    if @model.get('already_bought')
      @$el.find('.action').addClass('inactive')
      @$el.attr 'data-hint', """
        #{@model.get 'description'}<br/>
        (уже куплено)
      """      

  action: ->
    @purchase.show()

class MegaballWeb.Views.ItemsView extends MegaballWeb.Views.MasterView
  tagName: 'div'
  elements_per_page: 4
  page: 0

  initialize: ->
    console.log("Initialization items view")
    @router = @options.router
    @left_el = @options.left_el
    @right_el = @options.right_el
    @filter = @options.filter ? []
    @views = {}
    @items = []

  navigated: -> @render()

  render: (speed) ->
    return unless @items?
    skip = @elements_per_page * @page
    count = 0

    items = @array_limit(@items, @elements_per_page, skip)

    for item in items when not @views[item.get '_id']?
      view = @views[item.get '_id'] = new MegaballWeb.Views.ItemView model: item
      view.on 'success_buy', (x) => @trigger 'success_buy', x
      @$el.append view.$el
      view.$el.hide()

    @$el.find('.product').hide(speed)
    for item in items
      @views[item.get '_id'].$el.show(speed)

    if @is_last_page() then @right_el.addClass 'inactive'
    else @right_el.removeClass 'inactive'

    if @is_first_page() then @left_el.addClass 'inactive'
    else @left_el.removeClass 'inactive'

  next_page: ->
    if not @is_last_page()
      ++@page
      @render('fast')

  prev_page: ->
    if not @is_first_page()
      --@page
      @render('fast')

  is_last_page: -> @items.length <= @elements_per_page * (@page + 1)
  is_first_page: -> @page <= 0

  set_items: (items) ->
    @items = items.where category: @filter
    @views = {}
    @$el.html ''


class MegaballWeb.Views.SalesItemsView extends MegaballWeb.Views.ItemsView 
  set_items: (items) ->
    @items =items.filter (item)->
      item.get('sales')?

    @items.forEach (value, key)->
      sale_data = value.get 'sales'
      for key_sales, value_sales of sale_data
        if value.has key_sales
          value.set key_sales, value_sales