class MegaballWeb.Views.StarsView extends MegaballWeb.Views.MasterView
  template: _.template $("#ratestars_template").html()

  hundreds: ['.first', '.second', '.third', '.fourth']

  events:
    'click .small-plus':'improve'

  initialize: ->
    @user = @options.user
    @stat = @options.stat ? ''
    @render()

  render: ->
    @$el.html @template
    @$el.find('.rate-points').html(@user.get(@stat))

  improve: ->
    MegaballWeb.Views.PopupView.loading_show()
    improve = new MegaballWeb.Models.Improve @stat
    improve.on 'sync', @context -> @user.fetch success: ->
      MegaballWeb.Views.PopupView.loading_hide()
    improve.save()

  set_value: (value) ->
    value /= window.user_default.pumping_ticks
    value *= 100
    target = Math.floor value / 100
    for i in [0...target] when i < @hundreds.length
      @$el.find(@hundreds[i]).css('width', '100%')
    for i in [target+1...@hundreds.length] when i < @hundreds.length
      @$el.find(@hundreds[i]).css('width', '0%')
    @$el.find(@hundreds[target]).css('width', "#{value - 100 * target}%")
    @$el.find('.rate-points').html(@user.get(@stat))


class MegaballWeb.Views.ClothView extends MegaballWeb.Views.MasterView
  template: _.template """
    <div>
      <img />
      <span class='charge'></span>
    </div>
  """

  events:
    'click':'click'

  initialize: ->
    @model = @options.model
    @render()
 
  render: ->
    @$el = $ @template()
    @img = @$el.find('img')
    @charge = @$el.find('.charge')

    @img.attr 'src', @model.texture

    if @model.wasting
      @charge.html @model.charge
    else
      @charge.hide()

    if @model.description
      @$el.addClass 'has-hint'
      @$el.attr 'data-hint', @model.description

  click: -> @trigger 'click', @model
  
class MegaballWeb.Views.ProfileView extends MegaballWeb.Views.MasterView
  el: "#profile_block"

  parts: ['hair', 'eye', 'mouth']

  events:
    'click .small-plus':'improve'
    'click .to-avatar-button':'save_avatar'

  initialize: (@current_user) ->
    super
    console.log("Init Profile view")
    @picture = new MegaballWeb.Views.UserPictureView el: @$el.find('.picture')
    @picture.from_user @current_user
    @picture.set_params platform: 'simple'

    @editor = new MegaballWeb.Views.NameEditorView el: @$el.find('.username')
    @editor.set_user @current_user

    @items = new MegaballWeb.Models.UserItems
    @items.on 'sync', @context @sync_items

    @points = @$el.find '.points-left'
    @plusses = @$el.find '.stars .small-plus'
    @purchase_view = new MegaballWeb.Views.PurchaseView
    @$el.append @purchase_view.$el

    @star_el = @$el.find '.star-value'
    @coin_el = @$el.find '.coin-value'
    @action = @$el.find '.action'

    @reset_points_items = []
    for i in [0...window.resetPointsItems.length]
      @reset_points_items.push(new MegaballWeb.Models.Item window.resetPointsItems[i])

    @buy_points_item = new MegaballWeb.Models.Item window.buyPointsItem

    @case_types =
      0: 'extra'
      2: 'shirt'
      3: 'boots'
      4: 'amulets'
      6: 'pants'

    @weapons = new MegaballWeb.Views.WeaponsView
      el: @$el.find('.equipment')
      left_el: @$el.find('.button.store-left')
      right_el: @$el.find('.button.store-right')
      filter: (item) -> not item.active
      handler: @context @weapon_clicked
      hover_handler: @context @weapon_hover
      blur_handler: @context @weapon_blur

    @$el.find('.left.hair').click   => @prev_item 'hair'
    @$el.find('.left.eye').click    => @prev_item 'eye'
    @$el.find('.left.mouth').click  => @prev_item 'mouth'
    @$el.find('.right.hair').click  => @next_item 'hair'
    @$el.find('.right.eye').click   => @next_item 'eye'
    @$el.find('.right.mouth').click => @next_item 'mouth'

    @$el.find('.reset.points').click => @reset_points()
    @$el.find('.buy.points').click => @buy_points()

    @rates =
      kick_power: new MegaballWeb.Views.StarsView {
        el: @$el.find('.kick'),
        user: @current_user
        stat: 'kick_power'
      }

      move_force: new MegaballWeb.Views.StarsView {
        el: @$el.find('.speed'),
        user: @current_user,
        stat: 'move_force'
      }

      leg_length: new MegaballWeb.Views.StarsView {
        el: @$el.find('.radius'),
        user: @current_user,
        stat: 'leg_length'
      }

    @active =
      amulets: [@$el.find('.cloth.amulet_1'), @$el.find('.cloth.amulet_2')]
      extra: [@$el.find('.cloth.extra_1'), @$el.find('.cloth.extra_2'), @$el.find('.cloth.extra_3')]
      shirt: [@$el.find('.cloth.shirt')]
      pants: [@$el.find('.cloth.pants')]
      boots: [@$el.find('.cloth.boots')]

    @current_user.on 'sync', @context @render
    @render()

  save_avatar: =>
    window.social_service.set_avatar @current_user

  navigated: ->
    @items.fetch()
    @render()

  render: ->
    console.log("Render Profile view")

    # rates
    for k, v of @rates
      v.set_value Math.round(@current_user.get(k))

    # weapons
    if @current_user.get('weapons')?
      @render_active _.filter(@current_user.get('weapons'), (w) -> w.active)
      @weapons.set_items @current_user.get 'weapons'
    @weapon_blur()

    # points
    @points.text @current_user.get 'points'
    if Number(@current_user.get 'points') > 0 then @plusses.show()
    else @plusses.hide()

  render_active: (items) ->
    for k, v of @case_types
      @_render_active items, v, k

  _render_active: (items, active, type) ->
    limit = @active[active].length
    i = 0

    for item in @active[active]
      item.find('.def').show()
      item.find('div').html ''

    for item in items when Number(item.type) == Number(type)
      break if --limit < 0
      view = new MegaballWeb.Views.ClothView model: item
      view.on 'click', (model) =>
        MegaballWeb.Views.PopupView.loading_show()
        @item_status model._id
      el = @active[active][i++]
      el.find('div').append view.$el
      el.find('.def').hide()

  render_items: ->

    # Prepare params 
    params = _.object([
      i, @items.get("avail_#{i}")[@selected_items[i]]
    ] for i in @parts)

    #Update params (but not apply until animate fadout current set)
    @picture.set_raw_params params

    # Animate user
    @picture.animate _.object([
      k, @picture.default(k, v)
    ] for k, v of params), {
      callback: =>
        @queue 'save_face', =>
          @current_user.save params, patch: true
    }

    # Save user

  sync_items: ->
    # Match indexes to current user's items
    items = _.object([
      i
      @items.get("avail_#{i}").indexOf(Number @current_user.get i)
    ] for i in @parts)
    
    # Store selected
    @selected_items = items if items?
    @render_items()

  reset_points: ->
    experience = @current_user.get('experience')
    console.log("exp:"+experience)
    user_level = 0
    for user_level in [0...window.user_levels.length]
      break if experience<window.user_levels[user_level]
    console.log("level:"+user_level)
    for i in [0...@reset_points_items.length]
      item = @reset_points_items[i]
      break if user_level<=item.get('level_max')
    console.log("buy:"+item)
    @enable(item)
    @buy()

  buy_points: ->
    console.log("buy:"+@buy_points_item)
    @enable(@buy_points_item)
    @buy()

  enable: (item) ->
    type = item.get 'item_contents'
    return unless type?

    @purchase_view.set_model item, item.get 'texture', true
    @star_el.val if ((x = item.get 'stars') < 0) then window.sub_zero_price_stub else x
    @coin_el.val if ((x = item.get 'coins') < 0) then window.sub_zero_price_stub else x
    @action.removeClass 'inactive'

  disable: ->
    @action.addClass 'inactive'
    @star_el.val '---'
    @coin_el.val '---'

  buy: ->
    @purchase_view.show()

  next_item: (group) ->
    i = @selected_items[group] + 1
    i = 0 if i >= @items.get("avail_#{group}").length
    @selected_items[group] = i
    @render_items()

  prev_item: (group) ->
    i = @selected_items[group] - 1
    i = @items.get("avail_#{group}").length - 1 if i < 0
    @selected_items[group] = i
    @render_items()

  item_status: (id, active=false) ->
    @current_user.save {
      weapons:
        _id: id
        active: active
    },
      patch: true
      success: -> MegaballWeb.Views.PopupView.loading_hide()
      error: (model, xhr) ->
        MegaballWeb.Views.PopupView.loading_hide()
        response = $.parseJSON(xhr.responseText)
        if response.no_charge?
          MegaballWeb.Views.PopupView.alert "Пополните заряд!"
        if response.too_many?
          MegaballWeb.Views.PopupView.alert 'Заняты все свободные слоты! Освободите место.'

  weapon_clicked: (w) ->
    if w.wasting and (not w.charge? or w.charge == 0)
      MegaballWeb.Views.PopupView.alert "Пополните заряд!"
    else
      MegaballWeb.Views.PopupView.loading_show()
      @item_status w._id, true

  weapon_hover: (model) ->
    @$el.find(".cloth.type_#{@case_types[model.type]}").addClass('active')

  weapon_blur: (model) ->
    @$el.find(".cloth").removeClass('active')

  improve: (e) ->
    stat = $(e.currentTarget).attr 'data-stat'
