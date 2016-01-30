class MegaballWeb.Views.FreshManView extends MegaballWeb.Views.MasterView
  el: '#freshman'

  events:
    'click .join-group':'do_join_group'
    'click .get-friends':'do_get_friends'
    'click .set-picture':'do_set_picture'

  initialize: ->
    @current_user = @options.current_user
    @router = @options.router
    @step_join_group = @$el.find('.join-group')
    @step_get_friends = @$el.find('.get-friends')
    @step_set_picture = @$el.find('.set-picture')
    @avatar_set = !window.social_service.can_set_avatar()
    @tour_finished = @current_user.get('fresh_man_tour_finished')
    @show()

    window.u_events.once 'receive_avatar', @context @receive_avatar

    @router.on 'entered_game', @context @stop_updater
    @router.on 'leaved_game', @context @start_updater
    @check_group_status()
    @start_updater()

  start_updater: ->
    @interval = setInterval (@context @check_group_status), 5000

  stop_updater: ->
    clearInterval @interval if @interval?

  check_group_status: ->
    window.social_service.is_joined_group @current_user, (joined) => if joined
      @step_join_group.addClass('active')
      @check_freinds()

  check_freinds: ->
    if @current_user.get('friends_count') >= 3
      @step_get_friends.addClass('active')
      @check_avatar()

  check_avatar: ->
    if @avatar_set and not @tour_finished
      @step_set_picture.addClass('active')
      @get_prise()
  
  get_prise: ->
    @tour_finished = true
    @current_user.save {
      fresh_man_tour_finished: true
    }, {
      patch: true
      success: (res) =>
        @stop_updater()
        @router.gift @current_user.get 'fresh_man_bonus'
        @current_user.fetch()
        @hide()
    }

  show: ->
    @pwidth = $(document).width()
    @pheight = $(document).height()
    @$el.show()
    window.social_service.set_window_size @pwidth,
      (@pheight + 75)

  hide: ->
    @$el.hide('fast', =>
      window.social_service.set_window_size @pwidth, @pheight)
  
  do_join_group: ->
    window.social_service.navigate_to_group()

  do_get_friends: ->
    @router.navigate('/profile', true)
    window.social_service.invite_friends()

  do_set_picture: ->
    @router.navigate('/profile', true)
    if window.social_service.can_set_avatar()
      MegaballWeb.Views.PopupView.loading_show()
      window.social_service.set_avatar @current_user, {
        ready: => setTimeout (=> MegaballWeb.Views.PopupView.loading_hide()), 10000
      }

  receive_avatar: (res) ->
    MegaballWeb.Views.PopupView.loading_hide()
    @avatar_set = not res.error?
    @check_group_status()
    unless @avatar_set
      window.u_events.once 'receive_avatar', @context @receive_avatar
