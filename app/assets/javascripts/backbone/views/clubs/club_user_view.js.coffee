class MegaballWeb.Views.ClubUserView extends MegaballWeb.Views.MasterView
  template: _.template $("#club_user_template").html()

  events:
    'click > span:not(.user-kick)':'user_info'
    'click .kick':'kick'

  initialize: ->
    @model = @options.model
    @club_user = @options.club_user
    @index = @options.index ? 0
    @accent = @options.accent ? false
    @hide_kick = @options.hide_kick ? false
    @render()

  render: ->
    @$el = $ @template _.extend @model, {
      i: @index }
    @$el.css(fontWeight: 'bold') if @accent
    @$el.find('.kick').hide() if @hide_kick

  kick: ->
    MegaballWeb.Views.PopupView.confirm
      text: "Вы действительно хотите выгнать #{@model.name}?"
      ok: => @trigger 'kick', @model

  user_info: ->
    popup = new MegaballWeb.Views.ClubUserInfoView {
      club_user: @club_user
      model: @model
      hide_kick: @hide_kick }
    popup.on 'setrole', (m, r, s) => @trigger 'setrole', m, r, s
    popup.show()
