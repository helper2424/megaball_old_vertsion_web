class MegaballWeb.Views.MasterView extends Backbone.View

  buttons: [
    '.tab:not(.inactive)'
    '.button:not(.button .button):not(.inactive):not(.currency)'
  ]
  events: {}

  selectable: '.selectable'
  hints: '.has-hint'

  initialize: ->
    @queues = {}
    @__render = @render
    @render = =>
      @__render arguments if @__render
      @after_render()

  context: (cb) -> _.bind cb, @

  queue: (queue, fn, params) ->
    delay = params?.delay ? 1000
    clearTimeout @queues[queue] if @queues[queue]?
    @queues[queue] = setTimeout (=>
      fn()
      @queues[queue] = undefined
    ), delay

  array_limit: (array, limit, offset) ->
    dest = []
    for x in array
      continue if offset-- > 0
      break if limit-- <= 0
      dest.push x
    dest

  after_render: ->
    context = @

    # Sounded buttons
    for button in @buttons
      $(button).each ->
        if not $(@).is('.inactive') and $(@).attr('data-sounded') != 'sounded'
          $(@).attr('data-sounded', 'sounded')
          $(@).click context.play_sound

    # Hints
    context = @
    $(@hints).each ->
      if $(@).attr('data-hinted') != 'true'
        $(@).attr 'data-hinted', 'true'
        hint = null
        $(@).hover(
          (=> hint = MegaballWeb.Views.HintView.show $(@), $(@).attr('data-hint')),
          (=> hint.hide() unless hint == null)
        )
        $(@).click(=> hint.hide() unless hint == null; true)

  play_sound: (e) ->
    window.u_play_sound 0

  include: (clazz) -> _.extend @, clazz::
