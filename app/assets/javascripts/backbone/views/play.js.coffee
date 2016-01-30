#= require ./unity_view

class MegaballWeb.Views.PlayView extends MegaballWeb.Views.UnityView
  el: '#play_block'

  top: -106
  left: 0
  width: 800
  height: 620

  remove_frame: false

  navigated: ->
    super
    @router.entered_game()
    window.u_maximize_unity()

  navigated_from: ->
    super
    @router.leave_game()
