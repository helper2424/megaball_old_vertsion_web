class MegaballWeb.Views.WelcomeView extends MegaballWeb.Views.MasterView
  el: "#welcome_block"

  events:
    'click .button':'close'

  initialize: (@current_user) ->
    super
    console.log("Initialization welcome view")

  render: ->

  close: ->
    @hide_modal()
