window.u_bridge = "Bridges"
# Unity event binding
window.u_events = {}
_.extend(window.u_events, Backbone.Events)

# Initialization

#window.unity = { SendMessage: (bridge, message) -> console.log "#{bridge} <- #{message} (unity)" }
window.unity = {
  SendMessage: (bridge, message) ->
    x=1
}

window.u_receive_web_servers = ->
  window.unity = window.unityObject.getUnity?()
  window.unity.SendMessage("StateObject", "SetWebServers", $.toJSON({
    url: window.rootPath
    assetUrl: window.assetRootPath
    music_restriction: window.megaball_config.music_restriction
    can_wallpost: window.social_service.can_wallpost()
    game_url: window.social_service.game_link()
    first_time: window.megaball_config.first_time
  }))

window.u_ready = ->
  window.unity = window.unityObject.getUnity?()

  window.set_web_data = ->
    window.unity.SendMessage(window.u_bridge, "SetWebData", $.toJSON({url: window.rootPath, assetUrl: window.assetRootPath, music_restriction: window.megaball_config.music_restriction, can_wallpost: window.social_service.can_wallpost(), game_url: window.social_service.game_link(), first_time: window.megaball_config.first_time}))

  window.set_web_data()

window.u_loaded = ->

# Event

window.u_group_invitation = (player_id) ->
  console.log "GroupInvitation [#{player_id}] (< unity)"

window.u_group_disconnect = ->
  console.log "GroupDisconnect (< unity)"

window.u_group_action = (action, user_id, group_id) ->
  #console.log "GroupAction #{action} (> unity)"
  window.unity?.SendMessage window.u_bridge, "GroupAction", $.toJSON('action':action, 'user_id':user_id, 'group_id':group_id)

window.u_group_action_response = (result, user_id) ->
  console.log "GroupActionResponse [#{result}, #{user_id}] (< unity)"

window.u_game_end = ->
  console.log "GameEnd (< unity)"

window.u_quick_game = ->
  console.log "QuickGame (< unity)"

window.u_server_error = (error, message) ->
  console.log "ServerError[#{error}, #{message}] (< unity)"

window.u_play_sound = (sound) ->
  #console.log "PlaySound #{sound} (> unity)"
  window.unity?.SendMessage window.u_bridge, "PlaySound", sound

# MinMax

window.u_navigate = (route) ->
  MegaballWeb.main_router.navigate route, true

window.u_navigate_unity = (route) ->
  window.unity?.SendMessage window.u_bridge, "NavigateUnity", route

window.u_navigate_to_store_tab = (tabname) ->
  window.unity?.SendMessage window.u_bridge, "NavigateToStoreTab", tabname

window.u_fetch_user = ->
  MegaballWeb.main_router.current_user.fetch()

window.u_fetch_user_unity = ->
  window.unity?.SendMessage window.u_bridge, "FetchUserUnity"

window.u_group_lock = (lock) ->
  window.u_events.trigger 'group_lock', lock

window.u_minimize = ->
  console.log "Minimize (< unity)"

window.u_minimize_unity = ->
  console.log "Minimize (> unity)"
  window.unity?.SendMessage window.u_bridge, "Minimize", ""

window.u_maximize_unity = ->
  console.log "Maximize (> unity)"
  window.unity?.SendMessage window.u_bridge, "Maximize", ""

window.u_refresh = ->
  MegaballWeb.main_router.current_user.fetch()

# WallPost
window.u_wallpost_by_key = (photo_key, message) ->
  window.social_service.wallpost window.MegaballWeb.current_user, window.social_service.WALL_IMAGES[photo_key], messageб ""

window.u_wallpost_by_index = (photo_index, message) ->
  window.social_service.wallpost window.MegaballWeb.current_user, window.social_service.ACHIEVEMENT[photo_index], message, ""

# Avatar

window.u_receive_avatar = (data) ->
  MegaballWeb.Views.PopupView.loading_hide()
  console.log "Upload Avatar response: "+data
  d = JSON.parse(data)
  if d? and d.hash?
    params =
           server:d.server,
           hash:d.hash,
           photo:d.photo
    window.social_service.save_profile_photo params, (result) ->
      console.log(result)
      window.u_events.trigger 'receive_avatar', result
  else
    console.log "Bad response"

# Settings

window.u_music_on = ->
  window.u_events.trigger 'music_on'

window.u_music_off = ->
  window.u_events.trigger 'music_off'

window.u_music_unity = (val) ->
  if val
    window.unity?.SendMessage window.u_bridge, "MusicOn", ""
  else
    window.unity?.SendMessage window.u_bridge, "MusicOff", ""

window.u_sound_on = ->
  window.u_events.trigger 'sound_on'

window.u_sound_off = ->
  window.u_events.trigger 'sound_off'

window.u_sound_unity = (val) ->
  if val
    window.unity?.SendMessage window.u_bridge, "SoundOn", ""
  else
    window.unity?.SendMessage window.u_bridge, "SoundOff", ""

window.u_fullscreen_unity = (val) ->
  #if val
  #  window.unity.getUnity?()?.SendMessage window.u_bridge, "FullscreenOn", ""
  #else
  #  window.unity.getUnity?()?.SendMessage window.u_bridge, "FullscreenOff", ""

window.u_fullscreen_on = ->
	window.u_events.trigger 'fullscreen_on'

window.u_fullscreen_off = ->
  window.u_events.trigger 'fullscreen_off'

window.u_update_hints_stage = (hints) ->
  window.u_events.trigger 'update_hints_stage', hints
  
window.u_chat_connect = ->
  window.unity?.SendMessage window.u_bridge, "ChatConnect", ""

window.u_chat_receive_message = (sender, message) ->
  window.u_events.trigger 'chat_receive_message', {sender: sender, body: message}

window.u_chat_receive_system_message = (message) ->
  window.u_events.trigger 'chat_receive_system_message', message

window.u_chat_send_message = (message) ->
  window.unity?.SendMessage window.u_bridge, "ChatSendMessage", message
