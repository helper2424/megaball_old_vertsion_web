class MegaballWeb.Views.GiftView extends MegaballWeb.Views.MasterView
  el: "#gift_block"

  events:
    'click .button':'hide'

  navigated_modal: (prise) ->
    @prise = prise ? window.megaball_config.daily_gift
    return @hide() unless @prise?
    @$el.find('.prise').hide()
    @$el.find(".#{@prise}-gift").show()

  hide: ->
    @hide_modal()
