class MegaballWeb.Views.ClubEditor extends MegaballWeb.Views.MasterView
  initialize: ->
    @normal = @options.normal ? $("")
    @edit = @options.edit ? $("")
    @normal_controls = @options.normal_controls ? $("")
    @edit_controls = @options.edit_controls ? $("")
    @min_length = @options.min_length ? 0
    @max_length = @options.max_length
    @editing = false

    @max_length = +@edit.attr('maxlength') if not @max_length?

  start_edit: (val) ->
    @edit.val val ? @normal.text()
    @normal_controls.hide()
    @edit_controls.show()
    @normal.hide()
    @edit.show()
    @editing = true

  stop_edit: ->
    @normal_controls.show()
    @edit_controls.hide()
    @normal.show()
    @edit.hide()
    @editing = false

  accept: ->
    return false unless @editing
    edit_len = @edit.val().length
    return false if edit_len < @min_length or (@max_length? and edit_len > @max_length)
    @value = @edit.val()
    @stop_edit()
    @trigger 'accept', @
    true

  decline: ->
    return unless @editing
    @stop_edit()
    @trigger 'decline', @
