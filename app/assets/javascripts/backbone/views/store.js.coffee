class MegaballWeb.Views.PurchaseView extends MegaballWeb.Views.MasterView
  tag: 'div'
  template: _.template $("#purchase_template").html()

  events:
    'click .use-star:not(.inactive)':'use_star'
    'click .use-coin:not(.inactive)':'use_coin'
    'click .close':'close'

  initialize: ->
    super
    @$el = $ '<span/>'
    @router = @options.router ? {}
    @set_model @options.model
    @render()

  render: ->
    return unless @model?
    data = @model.toJSON()
    data['texture'] = @texture
    data['plain'] = @plain
    data['lock_coins'] = data.coins < 0
    data['lock_stars'] = data.stars < 0

    data.coins = window.sub_zero_price_stub if data.coins < 0
    data.stars = window.sub_zero_price_stub if data.stars < 0

    @$el.html @template data

  set_model: (model, texture, plain) ->
    return unless model?
    @model = model
    @texture = texture ? @model.get 'texture'
    @plain = plain ? false
    @render()

  use_star: ->
    console.log 'buy ' + @model.get('_id') + ' in stor by stars'
    @buy @model, 'star'

  use_coin: ->
    console.log 'buy ' + @model.get('_id') + ' in stor by coins'
    @buy @model, 'coin'

  show: -> @$el.children().show()
  close: -> @$el.children().hide()

  buy: (item, currency) ->
    $.ajax
      url: window.urls.store_buy
      type: "PUT"
      data:
        item: @model.get('_id')
        currency: currency
      context: @
      success: (object, status, jqXHR)->
        console.log 'success buy'
        window.u_play_sound 6
        MegaballWeb.main_router.refresh.fetch()
        @trigger 'success_buy'
        @close()
      error: (jqXHR, status, error)->
        console.log 'error buy'
        
        data = $.parseJSON jqXHR.responseText

        if data.error == 'not_enough_money'
          MegaballWeb.Views.NotEnoughMoney.show()
        else
          if data.description?
            new MegaballWeb.Views.PopupView.alert data.description
          else
            new MegaballWeb.Views.PopupView.alert(
              "В магазине произошла ошибка. Сообщите о ней разработчикам.")

        @close()


class MegaballWeb.Views.StoreView extends MegaballWeb.Views.MasterView
  el: "#store_block"
  current_tab: 'sales'

  events:
    'click .store-right':'next_page'
    'click .store-left':'prev_page'
    'click .faces .action:not(.inactive)':'buy'

  type_map:
    'bottles': 1
    'skills': 2
    'clothes': 3
    'sets': 4
    'faces': 5
    'shoes': 6
    'shorts': 7

  bg: 'store1'

  initialize: (@current_user, @refresh) ->
    super
    console.log("Initialization Store view")

    @tabs = new MegaballWeb.Views.MainTabs el: @$el.find('.tabs')
    @tabs.on 'navigate', @context @navigate

    @purchase_view = new MegaballWeb.Views.PurchaseView
    @$el.append @purchase_view.$el

    @left_el = @$el.find '.store-left'
    @right_el = @$el.find '.store-right'
    @star_el = @$el.find '.star-value'
    @coin_el = @$el.find '.coin-value'
    @action = @$el.find '.action'
    @loading = @$el.find '.loading'

    @user_pic = new MegaballWeb.Views.UserPictureView el: @$el.find(".faces .picture")
    @user_pic.from_user @current_user

    @product_views = {}
    for k, v of @type_map
      @product_views[k] = view = new MegaballWeb.Views.ItemsView
        el: @$el.find(".#{k}")
        left_el: @left_el
        right_el: @right_el
        filter: v
      view.on 'success_buy', => @items_fetch()

    @product_views['sales'] = view = new MegaballWeb.Views.SalesItemsView
        el: @$el.find(".sales")
        left_el: @left_el
        right_el: @right_el
        filter: v
    view.on 'success_buy', => @items_fetch()

    view = @product_views['faces'] = new MegaballWeb.Views.FaceItemsView
      el: @$el.find('.face-items'),
      left_el: @left_el,
      right_el: @right_el
      current_user: @current_user
      filter: @type_map['faces']
      enable: @context @enable
      disable: -> @context @disable

    @items = new MegaballWeb.Collections.ItemsCollection
    @items.on 'sync', _.bind(@render, @)

    @once 'navigated', =>
      @items_fetch()
      @refresh.on 'sync', @items_fetch, @

  navigated: ->
    @trigger 'navigated'

  items_fetch: ->
    #@loading.fadeIn 'fast', =>
    MegaballWeb.Views.PopupView.loading_show =>
      @items.fetch()

  render: () ->
    console.log("Render Store view")
    @items.sort()
    v.set_items @items for k, v of @product_views
    @navigate @current_tab
    #@loading.fadeOut()
    MegaballWeb.Views.PopupView.loading_hide()

  navigate: (tab) ->
    view = @product_views[tab]
    return unless view?
    cell = @$el.find ".cell.#{tab}"
    @current_tab = tab
    @$el.find(".store").removeClass(@bg) if @bg?
    @bg = cell.attr('data-bg') ? 'store1'
    @$el.find(".store").addClass(@bg)
    @$el.find(".products").hide()
    view = @product_views[tab]
    view?.navigated?()
    cell.show()
    @tabs.activate tab
    true

  next_page: -> @product_views[@current_tab].next_page()
  prev_page: -> @product_views[@current_tab].prev_page()

  enable: (item) ->
    @item = item
    type = item.get 'item_contents'
    return unless type?

    type = type[0].type
    params = {}
    params[type] = @user_pic.default type, Math.round(Number(item.get 'texture'))

    @user_pic.from_user @current_user
    content = item.get('item_contents')[0]
    @user_pic.set_raw_param content.type, content.content
    @user_pic.set_params params
    @purchase_view.set_model @item, @user_pic.to_html(), true
    @star_el.val if ((x = item.get 'stars') < 0) then window.sub_zero_price_stub else x
    @coin_el.val if ((x = item.get 'coins') < 0) then window.sub_zero_price_stub else x
    @action.removeClass 'inactive'

  disable: ->
    @action.addClass 'inactive'
    @star_el.val '---'
    @coin_el.val '---'

  buy: ->
    @purchase_view.show()
