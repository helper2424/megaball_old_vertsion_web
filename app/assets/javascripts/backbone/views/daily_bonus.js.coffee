class MegaballWeb.Views.DailyBonusView extends MegaballWeb.Views.MasterView
  el: "#daily_bonus_block"

  events:
    'click .button':'hide'

  initialize: ->
    @activable = @$el.find """
      .active-on-1,
      .active-on-2,
      .active-on-3,
      .active-on-4,
      .active-on-5
    """

  navigated_modal: (@day) ->
    @activable.removeClass 'active'
    @$el.find(".active-on-#{@day}").addClass 'active'

  hide: ->
    @hide_modal()
    @router.gift() if @day > 4
