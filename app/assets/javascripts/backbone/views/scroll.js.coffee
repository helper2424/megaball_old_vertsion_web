class MegaballWeb.Views.ScrollView extends MegaballWeb.Views.MasterView
  tagName: 'div'
  template: _.template $('#scroll_template').html()
  body_el: '.scroll-body'

  events:
    '':''

  initialize: ->
    super
    @html @$el.html()

  render: ->
    data = @template html: @html_body
    @$el.html data
    @update()

  scroll_down: ->
    @$el.find('.scroll').scrollTop(@$el.find('.scroll-body').height())

  update: ->
    hider = @$el.find '.scroll-hider'
    scroll = @$el.find '.scroll'
    body = @$el.find '.scroll-body'
    bar = @$el.find '.scroll-bar'
    handle = @$el.find '.scroll-handle'

    b = -> bar.height() - handle.height()
    h = -> body.height() - scroll.height()
    s = -> b() * scroll.scrollTop() / h()
    set_scroll = (y) -> scroll.scrollTop h() * (y - scroll.offset().top - dragging) / b()

    # Disable horizontal scrolling
    hider.scroll -> hider.scrollLeft 0

    # Display scrolling
    @redraw = -> handle.css top: "#{s()}px"
    scroll.scroll => @redraw()

    # Mouse scrolling
    dragging = false
    bar.mouseup (e) -> if not dragging then set_scroll e.pageY - (handle.height() / 2)
    handle.mousedown (e) -> dragging = e.pageY - scroll.offset().top - s()
    $(window).mouseup -> dragging = false
    $(window).mousemove (e) -> if dragging != false then set_scroll e.pageY

  html: (html) ->
    @html_body = html
    @$el.find(@body_el).html html
    @render()

  $: -> @$el.find(@body_el)
