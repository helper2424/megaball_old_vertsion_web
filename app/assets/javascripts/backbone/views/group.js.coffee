class MegaballWeb.Views.GroupView extends MegaballWeb.Views.MasterView
  template: _.template( $('#groups_template').html() )
  group_user_template: _.template $("#group_user_template").html()

  $isidle: -> $(".lock-when-isidle")
  $leader: -> $(".lock-when-leader")
  $member: -> $(".lock-when-member")
  $ingame: -> $(".lock-when-ingame")
  $all:    -> $(".lock-when-isidle,
                 .lock-when-leader,
                 .lock-when-member,
                 .lock-when-ingame")

  NOT_IN_GROUP = 0
  GROUP_LEADER = 1
  GROUP_MEMBER = 2

  GAME_IDLE    = 0
  GAME_PLAYING = 1

  events:
    'click .create-group':'create_group'
    'click .remove-from-group':'remove_from_group'

  initialize: ->
    super
    console.log("Initialization Group view")

    @router = @options.router
    @render()

    @group_members = @$el.find('.group-members')
    @create_group_button = @$el.find('.create-group')
    @router.current_user.on('sync', @sync_current_user)

    @group_members = new MegaballWeb.Views.ScrollView el: @group_members
    @group = null
    @pending = []

    window.u_group_action_response = @context (first, second) -> @group_action_response first, second
    window.u_group_invitation = @context @on_group_invitation

    @group_users = new MegaballWeb.Collections.UsersCollection
    @group_users.on a, @context(@render_group_members) for a in ['add', 'remove', 'reset']

    @user_status = NOT_IN_GROUP
    @game_status = GAME_IDLE

  render: ->
    console.log("Render Group view")
    @$el.html @template {}

  render_locks: ->
    @$all().removeClass('inactive')
    return if @user_status == NOT_IN_GROUP
    switch @game_status
      when GAME_IDLE
        @$isidle().addClass('inactive')
        switch @user_status
          when GROUP_MEMBER then @$member().addClass('inactive')
      when GAME_PLAYING
        @$ingame().addClass('inactive')

  sync_current_user: (user) ->
    @game_status = if user.get('ingame') then GAME_PLAYING else GAME_IDLE

  groups_show: ->
    @create_group_button.fadeOut 'fast', @context -> @group_members.$el.fadeIn 'fast'
    @render_locks()

  groups_hide: ->
    @user_status = NOT_IN_GROUP
    @group_members.$el.fadeOut 'fast', @context -> @create_group_button.fadeIn 'fast'
    @render_locks()

  create_group: ->
    @router.navigate '/main', true
    @reset_group()
    @message_shown = true
    window.u_group_action 1
    @user_status = GROUP_LEADER
    @groups_show()
    MegaballWeb.Views.PopupView.alert 'Пригласите друзей и нажмите "играть"'

  accept_group: ->
    @router.navigate '/main', true
    @pending[@uid] = undefined
    window.u_group_action 4, [], @uid
    @uid = undefined
    @user_status = GROUP_MEMBER
    @reset_group()
    @groups_show()

  decline_group: ->
    @pending[@uid] = undefined
    window.u_group_action 5, [], @uid
    @uid = undefined

  on_group_invitation: (id) ->
    return if @in_group
    return if @pending[id]?
    @pending[id] = true
    @uid = id
    user = window.users.get @uid
    name = user.get('name') ? 'Неизвестный друг'
    MegaballWeb.Views.PopupView.confirm
      text: "#{user.get 'name'} приглашает вас в группу. Принять?"
      ok: @context @accept_group
      cancel: @context @decline_group

  reset_group: ->
    @group_users.reset()
    @group_users.add @current_user
    @message_shown = false

  add_group_user: (uid) ->
    context = @
    user = window.users.get uid
    if user? then context.group_users.add user
    else
      collection = new MegaballWeb.Collections.UsersCollection
      collection.on 'sync', ->
        collection.each (model) ->
          console.log 'Loaded:', model
          window.users.add model
          context.group_users.add model
      collection.fetch data: { uids: uid }

  group_action_response: (result, uids) ->
    console.log 'group action response ' + result
    console.log uids

    switch result

      when "GROUP_CREATED"
        @router.navigate '/main', true
        if @is_group_owner and not @message_shown
          MegaballWeb.Views.PopupView.alert 'Чтобы начать игру нажмите "играть"'
        @reset_group()
        @groups_show()

      when 'USER_CONNECTED', 'CONNECTED'
        for uid in uids
          @add_group_user Number(uid)

      when 'USER_DISCONNECTED', 'USER_KICKED'
        cid = @current_user.get '_id'
        for uid in uids
          if Number(uid) == Number(cid)
            if result == 'USER_KICKED'
              MegaballWeb.Views.PopupView.alert 'Вас удалили из группы!'
            return @groups_hide()
          @group_users.remove @group_users.get Number(uid)

      when 'GROUP_REMOVED'
        @user_status = NOT_IN_GROUP
        @groups_hide()

      when 'LEADER_IN_MATCH'
        @game_status = GAME_PLAYING
        @render_locks()
        @router.navigate 'play', true

  render_group_members: ->
    context = @
    el = @group_members.$()
    el.html ''
    console.log @group_users
    @group_users.each @context (model) ->
      view = new MegaballWeb.Views.GroupUserView(
        model, (@user_status == GROUP_LEADER or @current_user.get('_id') == model.get('_id'))
      )
      el.append view.$el
