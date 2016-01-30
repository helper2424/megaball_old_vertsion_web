# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#= require jquery
#= require jquery.form
#= require ./hosts_bridge

unityObjectUrl = "http://webplayer.unity3d.com/download_webplayer-3.x/3.0/uo/UnityObject2.js"
if document.location.protocol == 'https:'
  unityObjectUrl = unityObjectUrl.replace "http://", "https://ssl-"
document.write '<script type="text\/javascript" src="' + unityObjectUrl + '"><\/script>'

config =
  width: Number window.megaball_config.width[0..-3]
  height: Number window.megaball_config.height[0..-3]
  params: enableDebugging: "0"

$ ->
  u = new UnityObject2 config
  window.unityObject = u

  $wrapper       = $ "#unityWrapper"
  $clubUploader  = $ "#clubLogoUploader"
  $navHelp       = $ "#navHelp"
  $installUnity  = $ ".installUnity"
  $missingScreen = $ "#unityPlayer .missing"
  $brokenScreen  = $ "#unityPlayer .missing" # also missing
  $window        = $ "#unityPlayer .whiteCover"

  $clubUploader.width(config.width)
               .height(config.height)
  $wrapper.width(config.width)
          .height(config.height)
          .fadeIn('fast')
  $navHelp.fadeIn('fast')

  $installUnity.click ->
    $missingScreen.addClass('instruction')
    $window.fadeOut('fast')
    u.installPlugin()

  $missingScreen.hide()
  $brokenScreen.hide()

  u.observeProgress (progress) ->
    if window.currentPluginStatus != progress.pluginStatus
      $.post '/user', { plugin_status: progress.pluginStatus }
    switch progress.pluginStatus
      when "broken"
        u.installPlugin()
        $brokenScreen.show()
      when "missing"
        u.installPlugin()
        $missingScreen.show()
      when "installed" then $missingScreen.remove()
				
      #when "first"
  u.initPlugin $("#unityPlayer")[0], window.unity_source
