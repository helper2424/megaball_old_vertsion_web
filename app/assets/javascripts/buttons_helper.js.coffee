$.fn.inactive = () -> $(@).each ->
  $(@).attr('disabled','disabled')
  if not $(@).is('inactive') then $(@).addClass('inactive')

$.fn.active = () -> $(@).each ->
  $(@).removeAttr('disabled')
  $(@).removeClass('inactive')

