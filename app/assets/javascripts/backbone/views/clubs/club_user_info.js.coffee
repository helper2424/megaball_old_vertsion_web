#= require ./../popup

class MegaballWeb.Views.ClubUserInfoView extends MegaballWeb.Views.ScalablePopupView
  u_template: _.template $("#club_user_info_template").html()

  events:
    'click .make-manager:not(.inactive)':'make_manager'

  initialize: ->
    @model = @options.model
    @user = new MegaballWeb.Models.User @model
    @hide_kick = @options.hide_kick ? false
    @club_user = @options.club_user
    @user = new MegaballWeb.Models.User @model
    @options.text = @u_template _.extend @model, {
      level: @user.get_level()
      last_visit: @model.last_daily_bonus.toString().format_date()
      leaves: (@model.played_fast_matches - @model.ended_fast_matches)
      link: @user.provider_info().link
    }
    @options.buttons = ['close']
    super @options
    @on = MegaballWeb.Views.MasterView::on

  render: ->
    super
    @$el.addClass 'club-user-info'

  set_content: ->
    super
    @userpic = new MegaballWeb.Views.UserPictureView {
      el: @$el.find('.userpic')
      platform: 'simple' }
    @userpic.from_user @user
    if @club_user.role == 0 or @hide_kick
      @$el.find('.make-manager').hide()
    else
      @$el.find('.make-manager').show()
      @$el.find('.make-manager span').html(
        if @model.role == 0 then 'сделать руководителем'
        else 'разжаловать')

  make_manager: ->
    @trigger 'setrole', @model, (
      if @model.role == 0 then 1
      else 0), @

