class MegaballWeb.Views.NewLevelView extends MegaballWeb.Views.MasterView
  el: "#new_level_block"

  events:
    'click .do-hide':'hide'
    'click .to-shop':'to_shop'
    'click .to-profile':'to_profile'

  initialize: (@current_user) ->
    super
    console.log("Initialization new level view")
    @level = @$el.find('.level')
    @profile = @$el.find('.button.to-profile span')

    if window.social_service.can_wallpost()
      @profile.text 'на стену'
    else
      @profile.text 'в профиль'

  navigated_modal: ->
    @level.text @current_user.get_level()

  render: ->

  to_shop: ->
    @hide_modal 'store'

  to_profile: ->
    if window.social_service.can_wallpost()
      window.social_service.wallpost(
        @current_user,
        window.social_service.NEW_LEVEL,
        "Я получил #{@current_user.get_level()} уровень в новой игре Megaball! #{window.social_service.game_link()}",
        "")
    else
      @hide_modal 'profile'

  hide: ->
    @hide_modal()
