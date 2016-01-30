class MegaballWeb.Social.Vkontakte extends MegaballWeb.Social.Default

  NEW_LEVEL: '217194544_312012727'
  ACHIEVEMENT: [
    "217194544_314873105"
    "217194544_314873080"
    "217194544_314873099"
    "217194544_314873071"
    "217194544_314873073"
    "217194544_314873086"
    "217194544_314873112"
    "217194544_314873076"
    "217194544_314873064"
    "217194544_314873110"
    "217194544_314873068"
    "217194544_314873101"
    "217194544_314873089"
    "217194544_314873063"
    "217194544_314873085"
    "217194544_314873076"
    "217194544_314873094"
    "217194544_314873059"
    "217194544_314873078"
  ]

  WALL_IMAGES: {
    game_result: "217194544_319255992"
    medal_support: "217194544_319255831"
    medal_goalkeeper: "217194544_319255833"
    medal_forward: "217194544_319255830"
    medal_best_player: "217194544_319255828"
  }

  can_wallpost: -> true
  can_set_avatar: -> true

  wallpost: (user, photo_id, message, title) ->
    provider = user.provider_info()
    VK.api('wall.post', {
      owner_id: provider.uid
      attachments: "photo#{photo_id},http://vk.com/megaball_game"
      message: message
    }, _.bind(@save_wall_posts, @))

  energy_request_box: (user) ->
    VK.callMethod('showRequestBox',
      user.provider_info().uid,
      @ENERGY_MESSAGE,
      Math.random() + ""
    )

  save_wall_posts: ->
    set_wallpost_result if data.response
      VK.callMethod('saveWallPost', {
        hash: data.response["post_hash"]
      })
      true
    else
      MegaballWeb.Views.PopupView.alert 'Упс! Возникла ошибочка!'
      false
  
  set_avatar: (user, options={}) ->
    $('.to-avatar-button').inactive()
    MegaballWeb.Views.PopupView.loading_show()
    VK.api "photos.getProfileUploadServer", {}, (data) =>
      window.unity?.SendMessage window.u_bridge, "VKAvatarUpload", JSON.stringify {
        eye: user.get('eye')
        hair: user.get('hair')
        mouth: user.get('mouth')
        proxy_url: window.avatarUploaderUrl,
        upload_url: data.response.upload_url
      }

  save_profile_photo: (params,callback) ->
    console.log("saveProfilePhoto")
    $('.to-avatar-button').active()
    VK.api('photos.saveProfilePhoto',params,callback)

  show_freshman_bar: -> true

  navigate_to_group: -> window.open("http://vk.com/megaball_official", "_blank")

  invite_friends: -> VK.callMethod('showInviteBox')

  set_window_size: (w, h) -> VK.callMethod("resizeWindow", w, h)

  is_joined_group: (user, cb) ->
    console.log 'call'
    VK.api('groups.isMember', {
      group_id: 'megaball_official'
      user_id: user.provider_info().uid
      extended: 1
    }, (data) -> cb?(data.response.member != 0))

  help_me: ->
    if window.help_url
      window.open window.help_url
    else
      MegaballWeb.Views.PopupView.alert 'Упс! Возникла ошибочка!'

  friends_source: ->
    return 'vkontakte'

  download_users: (uids, add_in_collection, callback, context)->
    VK.api('users.get', {uids:uids.toString(), fields:'nickname, screen_name, photo_100'}, https:1, (data) ->
      if data.response and data.response.length
        for user in data.response
          context.add_in_collection {
            id: user.uid
            name: user.first_name + ' ' + user.last_name
            image: user.photo_100
          }

        callback()
    )

  show_invite_box: ->
    VK.callMethod('showInviteBox')

  user_page: (uid) ->
    "http://vk.com/id"+uid

  game_link: -> "http://vk.com/megaball_game"

