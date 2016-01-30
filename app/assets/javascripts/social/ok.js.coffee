class MegaballWeb.Social.OK extends MegaballWeb.Social.Default

  NEW_LEVEL: 'logo'
  ACHIEVEMENT: [
    '1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19'
  ]

  WALL_IMAGES: {}

  can_wallpost: -> true
  can_set_avatar: -> false

  wallpost: (user, photo_id, message, title) ->
    window.ok_stream_publish_object = {message: message, image: "achievement_post_images/#{photo_id}.png"}
    FAPI.UI.showConfirmation "stream.publish", message,'signature'

  energy_request_box: (user) ->
    FAPI.UI.showNotification(
      @ENERGY_MESSAGE,
      "",
      "0;" + user.provider_info().uid + ""
    )

  set_wallpost_result: (resp) ->
    @trigger 'wallpost', resp

  show_freshman_bar: -> true

  set_avatar: (user, options={}) ->
    true

  navigate_to_group: -> window.open("http://www.odnoklassniki.ru/group/51766710042764", "_blank")

  invite_friends: -> 
    FAPI.UI.showInvite 'Помоги мне победить в чемпионате', ''

  is_joined_group: (user, cb) -> 
    FAPI.Client.call {"method":"group.getUserGroupsByIds", "group_id":"51766710042764", "uids":user.provider_info().uid}, (status, data, error) ->
      if status == "ok"
        if data and data.length
          cb?(data.length != 0)
      else
        console.log "ERROR : " +error.error_msg+"("+error.error_code+")" 

  set_window_size: (w, h) ->
    FAPI.UI.setWindowSize(w, h);

  get_upload_profile_photo_url: ->
    MegaballWeb.Views.PopupView.alert "Невозможно сменить аватарку в соц. сети!"

  save_profile_photo: (params,callback) ->
    MegaballWeb.Views.PopupView.alert "Невозможно сменить аватарку в соц. сети!"

  help_me: ->
  	window.open "http://www.odnoklassniki.ru/group/51766710042764/topic/62288989140364"

  friends_source: ->
    return 'odnoklassniki'

  download_users: (uids, add_in_collection, callback, context) ->
    FAPI.Client.call {"method":"users.getInfo", "uids": uids, "fields":'name, first_name, last_name, pic_5' , "emptyPictures": false}, (status, data, error) ->
      if status == "ok"
        if data and data.length
          for user in data
            context.add_in_collection {
              id: user.uid
              name: user.first_name + ' ' + user.last_name
              image: user.pic_5
            }

        callback()
      else
        console.log "ERROR : " +error.error_msg+"("+error.error_code+")" 

  show_invite_box: ->
    FAPI.UI.showInvite 'Помоги мне победить в чемпионате', ''

  user_page: (uid) ->
    "http://www.odnoklassniki.ru/profile/"+uid

  game_link: -> "http://www.odnoklassniki.ru/game/207182080"
