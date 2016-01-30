class MegaballWeb.Views.TexteditView extends MegaballWeb.Views.MasterView
  tagName: 'div'
  template: _.template $('#textedit_template').html()

  initialize: ->
    super
    @icon = @$el.attr("data-icon")
    @text = @$el.html()
    @password = @$el.attr("data-password") == "true"
    @render()

  render: ->
    data = @template icon: @icon, password: @password
    @$el.html data
    @$el.css position: 'relative'
    @$el.find('.text-source').val(@text)

  value: -> @$el.find('.text-source').val()

  $: -> @$el.find('.text-source')
