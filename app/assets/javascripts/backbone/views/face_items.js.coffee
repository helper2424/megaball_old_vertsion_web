class MegaballWeb.Views.FaceItemEntryView extends MegaballWeb.Views.MasterView
  template: _.template $('#face_item_template').html()

  events:
    'click':'click'

  initialize: ->
    @model = @options.model
    @current_user = @options.user
    @category = @options.category
    @locked = _.contains(@current_user.get("avail_#{@category}"), Number(@model.get 'texture'))

    @render()

  render: ->
    data = @model.toJSON()
    data.coins = window.sub_zero_price_stub if data.coins < 0
    data.stars = window.sub_zero_price_stub if data.stars < 0
    data.locked = @locked

    @$el = $ @template data

    # Setup preview
    @user_pic = new MegaballWeb.Views.UserPictureView el: @$el.find('.preview'), dont_render: true
    params = small: true, only: [@category]
    params[@category] = @user_pic.default(@category, Math.round(Number(@model.get 'texture')))
    @user_pic.set_params params

  click: ->
    return if @locked
    @trigger 'click', @model

class MegaballWeb.Views.FaceItemsView extends MegaballWeb.Views.MasterView
  tagName: 'div'
  template: _.template $('#face_item_template').html()
  skip_template: _.template '<div class="skip"></div>'
  empty_template: _.template '<div class="empty"></div>'
  elements_per_page: 4
  delim_each: 2
  page: 0

  types: ['hair', 'eye', 'mouth']
  count_by: 7

  initialize: ->
    super
    console.log("Initialization items view")
    @left_el = @options.left_el
    @right_el = @options.right_el
    @enable = @options.enable
    @disable = @options.disable
    @filter = @options.filter
    @current_user = @options.current_user ? {}
    @views = {}

    @els = {}
    for x in @types
      @$el.append(@els[x] = $ '<div class=category />')

    @filter_cache = []

  navigated: -> @render()

  render: () ->
    @$el.find('.face-item').hide()
    for c in @types
      @render_category c

    if @is_last_page() then @right_el.addClass 'inactive'
    else @right_el.removeClass 'inactive'

    if @is_first_page() then @left_el.addClass 'inactive'
    else @left_el.removeClass 'inactive'

  filter_category: (c) ->
    return @filter_cache[c] if @filter_cache[c]?
    @filter_cache[c] = @items.filter((m) -> (a = m.get('item_contents')).length > 0 && a[0].type == c)

  render_category: (c) ->
    skip = @elements_per_page * @page
    count = 0
    items = @array_limit(@filter_category(c), @elements_per_page, skip)

    for item in items when not @views[item.get '_id']?
      @views[item.get '_id'] = view = new MegaballWeb.Views.FaceItemEntryView {
        model: item
        user: @current_user
        category: item.get('item_contents')?[0]?.type
      }
      view.on 'click', @context @update_main
      @els[c].append view.$el

    for i, item of items
      view = @views[item.get '_id']
      view.$el.show()
      view.$el.removeClass 'with-space'
      view.$el.addClass 'with-space' if i > 0 and i % @delim_each == 0

  next_page: ->
    if not @is_last_page()
      ++@page
      @render()

  prev_page: ->
    if not @is_first_page()
      --@page
      @render()

  is_last_page: -> @length <= @elements_per_page * (@page + 1)
  is_first_page: -> @page <= 0

  set_items: (items) ->
    @face_items = items.where(category: @filter)
    @items = items.where category: @filter
    @length = _.max (@filter_category(x).length for x in @types)

    @views = {}
    x.html '' for x in @els

  update_main: (it) ->
    unless it?
      @disable()
    else
      @enable(it)
