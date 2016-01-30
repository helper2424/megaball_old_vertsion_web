#= require ./../popup

class MegaballWeb.Views.ClubTransferView extends MegaballWeb.Views.ScalablePopupView

  events:
    'click .do-transfer':'do_transfer'

  style: 'contrast'
  render_params: {
    heading: 'перевод в клуб' }

  initialize: ->
    @options.buttons = ['close']
    @options.text = $("#club_transfer_template").html()
    @options.default_close = 'hide'
    super @options
    @on = MegaballWeb.Views.MasterView::on

  show: (args={}) ->
    super {
      stars: args.stars ? 0
      coins: args.coins ? 0
    }, 'fast'

  do_transfer: ->
    @trigger 'act', {
      stars: Number(@$el.find('.stars').val())
      coins: Number(@$el.find('.coins').val()) }
