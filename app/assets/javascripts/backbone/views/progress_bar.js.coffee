class MegaballWeb.Views.ProgressBarView extends MegaballWeb.Views.MasterView
  tagName: 'div'
  template: _.template $('#progress_bar_template').html()

  events:
    '':''
    #'click':'test'

  initialize: ->
    super
    @style = @options.style ? ''
    @value = 0
    @render()

  render: ->
    @$el.html @template text: @text_data, style: @style

  text: (text) ->
    @text_data = text
    @render()

  set_value: (@value) ->
    @$el.find('.cover').css {
      width: "#{@value}%"
    }
    @$el.find('.flash').hide()

  animate_value: (value) ->
    if value == @value
      @set_value @value
    else
      @$el.find('.cover').css({
        width: "#{@value}%"
      }).animate {
        width: "#{@value = value}%"
      }
      @$el.find('.flash').fadeIn().fadeOut()

  test: ->
    @animate_value _.random(0, 100)
