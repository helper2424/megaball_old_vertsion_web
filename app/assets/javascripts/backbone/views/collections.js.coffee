class MegaballWeb.Views.CollectionItemView extends MegaballWeb.Views.MasterView
  template: _.template $("#collection_item_template").html()

  initialize: ->
    @data = @options.data
    @render()

  render: ->
    @$el = $ @template {
      texture: @get_texture @data.texture_id, @data.active
    }

  get_texture: (id, active = false) ->
    "#{window.assetRootPath}/collections/#{id}_#{if active then 'active' else 'inactive'}.png"

class MegaballWeb.Views.CollectionView extends MegaballWeb.Views.MasterView
  template: _.template $("#collection_template").html()

  initialize: ->
    @model = @options.model

    @$el = $ @template @model.toJSON()
    @items_el = @$el.find '.coll-items'
    @render()

  render: (speed) ->

    items = @model.get('collection_item')

    @items_el.html ''
    for item in items
      view = new MegaballWeb.Views.CollectionItemView {
        data: item
      }
      view.$el.hide()
      @items_el.append view.$el
      
    @items_el.find('.collection-entry').show(speed)


class MegaballWeb.Views.CollectionsView extends MegaballWeb.Views.MasterView

  items_per_page: 3

  events:
    'click .store-right:not(.inactive)':'right'
    'click .store-left:not(.inactive)':'left'

  initialize: ->
    @refresh = @options.refresh

    @items_el = @$el.find('.items')
    @left_el = @$el.find('.store-left')
    @right_el = @$el.find('.store-right')

    @current_page = 0
    @once 'first', => @first()

  navigated: ->
    @trigger 'first'
    @collections.fetch()

  first: ->
    @collections = new MegaballWeb.Collections.Collections
    @collections.on 'sync', => @update()
    @refresh.on 'sync', => @collections.fetch()

  update: ->
    @items_el.html ''
    @views = []
    @current_page = 0
    @collections.each (model) =>
      view = new MegaballWeb.Views.CollectionView {
        model: model
      }
      view.$el.hide()
      @views.push view
      @items_el.append view.$el
    @render()

  render: (speed) ->
    offset = @current_page * @items_per_page

    @$el.find('.collection-item').hide(speed)
    for i in [offset...offset + @items_per_page]
      break if i >= @views.length
      view = @views[i]
      view.$el.show speed

    @left_el.removeClass 'inactive'
    @left_el.addClass 'inactive' if @is_first_page()
    @right_el.removeClass 'inactive'
    @right_el.addClass 'inactive' if @is_last_page()

  is_last_page: -> @items_per_page * (@current_page+1) >= @views.length
  is_first_page: -> @current_page == 0

  right: -> unless @is_last_page()
    @current_page += 1
    @render('fast')

  left: -> unless @is_first_page()
    @current_page -= 1
    @render('fast')
