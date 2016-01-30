class MegaballWeb.Social.MailRu extends MegaballWeb.Social.Default

  ENERGY_IMAGE: "#{window.assetRootPath}/energy_request.png"

  NEW_LEVEL: 'logo'
  ACHIEVEMENT: [
    '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19'
  ]

  WALL_IMAGES: {}
  mailru_user_names: {}

  can_wallpost: -> true
  can_set_avatar: -> true

  wallpost: (user, photo_id, message, title) ->
    mailru.common.stream.post({'title':title, 'text': message, 'img_url':"#{window.assetRootPath}/achievement_post_images/#{photo_id}.png"})

  energy_request_box: (user) ->
    mailru.app.friends.request {
      text: @ENERGY_MESSAGE
      image_url: @ENERGY_IMAGE
      friends: [user.provider_info().uid]
      hash: Math.random() + ""
    }

  set_wallpost_result: (resp) ->
    @trigger 'wallpost', resp

  show_freshman_bar: -> true

  set_avatar: (user, options={}) ->
    $('.to-avatar-button').inactive()
    MegaballWeb.Views.PopupView.loading_show()
    window.unity?.SendMessage window.u_bridge, "VKAvatarUpload", JSON.stringify {
      eye: user.get('eye')
      hair: user.get('hair')
      mouth: user.get('mouth')
      proxy_url: window.avatarMailruUploaderUrl
      upload_url: ''
    }

  navigate_to_group: -> window.open("http://my.mail.ru/community/megaballofficial", "_blank")

  invite_friends: -> 
    mailru.app.friends.invite()

  is_joined_group: -> false

  set_window_size: (w, h) -> 
    mailru.app.utils.setHeight(h)

  save_profile_photo: (params,callback) ->
    console.log("save_profile_photoeProfilePhoto")
    $('.to-avatar-button').active()
    mailru.common.photos.uploadAvatar({ url: params['photo'] })
    callback()

  get_upload_profile_photo_url: ->
    MegaballWeb.Views.PopupView.alert "Невозможно сменить аватарку в соц. сети!"

  help_me: ->
  	window.open 'http://my.mail.ru/community/megaballofficial/24AA8DA4E6C7FB5C.html?reply=1'

  friends_source: ->
    return 'mailru'

  download_users: (uids, add_in_collection, callback, context)->
    that = this
    mailru.common.users.getInfo( 
      (data)->
        if data and data.length
          for user in data
            that.mailru_user_names[user.uid.toString()] = user.nick
            context.add_in_collection {
              id: user.uid
              name: user.first_name + ' ' + user.last_name
              image: user.pic
            }

        callback()
      ,uids
    )

  show_invite_box: ->
    mailru.app.friends.invite() 

  user_page: (uid) ->
    nick = @mailru_user_names[uid]
    nick? ? "http://my.mail.ru/mail/"+nick.toString()+"/" : ""


  game_link: -> "http://my.mail.ru/apps/715002"
