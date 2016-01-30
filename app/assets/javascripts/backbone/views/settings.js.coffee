class MegaballWeb.Views.SettingsView extends MegaballWeb.Views.MasterView
  el: "#settings_block"

  events:
    'click .sound-toggle':'sound_toggle'
    'click .music-toggle':'music_toggle'
    'click .fullscreen-toggle':'fullscreen_toggle'
    'click .controls':'goto_control'
    'click .close':'hide'

  initialize: (@current_user) ->
    super
    console.log("Initialization Settings view")
    context = @

    @sound_el = @$el.find('.sound-toggle')
    @music_el = @$el.find('.music-toggle')
    @fullscreen_el = @$el.find('.fullscreen-toggle')

    if @current_user?
      @sound = @current_user.get 'sound_on'
      @music = @current_user.get 'music_on'
    else
      @sound = false
      @music = false

    window.u_events.on 'sound_on', _.bind(@sound_on_handler, @)
    window.u_events.on 'sound_off', _.bind(@sound_off_handler, @)
    window.u_events.on 'music_on', _.bind(@music_on_handler, @)
    window.u_events.on 'music_off', _.bind(@music_off_handler, @)
    window.u_events.on 'fullscreen_on', _.bind(@fullscreen_on_handler, @)
    window.u_events.on 'fullscreen_off', _.bind(@fullscreen_off_handler, @)
    window.u_events.on 'update_hints_stage', @context @update_hints_stage

    @current_user.on 'sync', @sync_user, @

  render: ->
    console.log("Render Settings view")
    
    window.u_sound_unity @sound
    window.u_music_unity @music
    window.u_fullscreen_unity @fullscreen

    if @music then @music_el.addClass 'active'
    else @music_el.removeClass 'active'

    if @sound then @sound_el.addClass 'active'
    else @sound_el.removeClass 'active'

    if @fullscreen then @fullscreen_el.addClass 'active'
    else @fullscreen_el.removeClass 'active'

  sound_toggle: (s) ->
    @sound = not @sound
    window.u_sound_unity(@sound)
    @render()
    @save_vals()

  sound_on_handler: ->
    @sound = true
    @render()
    @save_vals()

  sound_off_handler: ->
    @sound = false
    @render()
    @save_vals()

  music_toggle: ->
    @music = not @music
    window.u_sound_unity(@music)
    @render()
    @save_vals()

  music_on_handler: ->
    @music = true
    @render()
    @save_vals()

  music_off_handler: ->
    @music = false
    @render()
    @save_vals()
	
  fullscreen_toggle: ->
    @fullscreen = not @fullscreen
    window.u_fullscreen_unity(@fullscreen)
    @render()
    @save_vals()

  fullscreen_on_handler: ->
    @fullscreen = true
    @render()
    @save_vals()

  fullscreen_off_handler: ->
    @fullscreen = false
    @render()
    @save_vals()

  sync_user: ->
    @sound = @current_user.get 'sound_on'
    @music = @current_user.get 'music_on'
    @fullscreen = @current_user.get 'fullscreen_on'
    @render()

  save_vals: ->
    @current_user.save {
        sound_on: @sound
        music_on: @music
        fullscreen_on: @fullscreen
      },
      patch: true

  hide: ->
    @hide_modal()

  goto_control: ->
    @hide_modal '/user_control'

  update_hints_stage: (hints) ->
    @current_user.save {
      stage: hints
    },
      patch: true
