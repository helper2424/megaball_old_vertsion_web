class MegaballWeb.Views.UnityView extends MegaballWeb.Views.MasterView
  el: '#play_block'

  top: 0
  left: 10
  width: 790
  height: 373

  remove_frame: true

  initialize: ->
    @scene = @options.scene
    @not_frame = @$el.hasClass('not-frame')

  navigated: ->
    @$el.css {
      position: 'relative'
      top: @top + "px"
      left: @left + "px"
      width: @width + "px"
      height: @height + "px"
    }
    @$el.find("embed, object")
      .width(@width).attr('width', @width)
      .height(@height).attr('height', @height)
    if @remove_frame
      @$el.removeClass('not-frame')
    window.u_navigate_unity @scene if @scene?

  navigated_from: ->
    @$el.css {
      position: 'fixed'
      top: '-1000px'
      left: '100%'
      width: '800px'
      height: '620px'
    }
    @$el.find("embed, object")
      .width(800).attr('width', 800)
      .height(620).attr('height', 620)
    @$el.addClass('not-frame') if @not_frame
    #window.u_minimize_unity()
