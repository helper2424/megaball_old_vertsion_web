#= require ./unity_view

class MegaballWeb.Views.UnityStoreView extends MegaballWeb.Views.UnityView

  initialize: ->
    @options.scene = 'store'
    super

  navigated: (tab) ->
    super
    window.u_navigate_to_store_tab tab
