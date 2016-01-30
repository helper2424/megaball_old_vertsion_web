class MegaballWeb.Social.Default

  ENERGY_MESSAGE: "Помоги мне получить энергию :)"

  NEW_LEVEL: ''
  ACHIEVEMENT: [ ]
  WALL_IMAGES: {}

  achievement_message: (title) ->
    "Я получил достижение #{title} в новой игре Megaball!"

  can_wallpost: -> false
  can_set_avatar: -> false

  wallpost_button_title: -> "показать"

  wallpost: (user, photo_id, img_id, title) ->
    MegaballWeb.Views.PopupView.alert "Невозможно поделиться в соц. сети!"

  energy_request_box: (user) ->

  set_wallpost_result: (resp) ->
    @trigger 'wallpost', resp

  show_freshman_bar: -> false

  set_avatar: (user, options={}) ->
    MegaballWeb.Views.PopupView.alert "Невозможно установить автатарку в соц. сети!"

  navigate_to_group: -> false

  invite_friends: -> false

  is_joined_group: -> false

  set_window_size: (w, h) -> false

  get_upload_profile_photo_url: ->
    MegaballWeb.Views.PopupView.alert "Невозможно сменить аватарку в соц. сети!"

  save_profile_photo: (params,callback) ->
    MegaballWeb.Views.PopupView.alert "Невозможно сменить аватарку в соц. сети!"

  help_me: ->
  	MegaballWeb.Views.PopupView.alert "Эта кнопка пока не работает"

  friends_source: ->
    return null

  download_users: (uids, add_in_collection, callback)->
    return null

  show_invite_box: ->
    MegaballWeb.Views.PopupView.alert "Вне социальных сетей невозможно приглашать друзей"

  user_page: (uid) ->
    null

  game_link: -> ""
