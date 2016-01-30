#= require ./../popup

class MegaballWeb.Views.ClubCreateView extends MegaballWeb.Views.ScalablePopupView
  render_params: {
    heading: 'создание клуба' }

  style: 'contrast'

  events:
    'click .do-create':'create_club'

  initialize: ->
    @options.text = $("#create_club_template").html()
    @options.buttons = ['close']
    @currency = @options.currency
    super @options
    @on = MegaballWeb.Views.MasterView::on

  create_club: ->
    @$el.find(".name, .short_name").removeClass("invalid")
    $.ajax
      url: "/club/new"
      type: 'POST'
      data: {
        name: @$el.find(".name").val()
        short_name: @$el.find(".short_name").val()
      }

      error: (xhr) => 
        @server_error()
        @dispose()

      success: (obj) =>
        if not obj.error?
          @dispose()
          @trigger 'created'
        else if obj.error == "not_enough_money" then @not_enough_money()
        else
          if obj.error.name?
            @$el.find(".name").addClass('invalid')
          if obj.error.short_name?
            @$el.find(".short_name").addClass('invalid')

  server_error: ->

  not_enough_money: ->
    MegaballWeb.Views.NotEnoughMoney.show()
