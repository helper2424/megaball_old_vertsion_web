class MegaballWeb.Views.PickerView extends MegaballWeb.Views.MasterView
  template: _.template $('#user_control_picker_template').html()

  events:
    'click .picker':'catch'

  max_len: 2

  allowed_chars: (char) ->
    'a' <= char <= 'z' or
      'A' <= char <= 'Z' or
      '0' <= char <= '9'

  map_code: (code) ->
    switch code
      when 'UP' then 'вверх'
      when 'LEFT' then 'влево'
      when 'DOWN' then 'вниз'
      when 'RIGHT' then 'вправо'
      else code.toLowerCase()

  initialize: ->
    @default = @options.default ? ''
    @option = @options.option ? ''
    @title = @options.title ? ''
    @keys_repo = @options.keys_repo ? ''
    @current_user = @options.current_user
    @render()

    @codes = @current_user?.get('user_control')[@option]
    @keys_repo.bind x, this for x in @codes
    @render_codes()
    $(document).on 'keydown', @context @process

  render: ->
    @$el = $ @template {
      title: @title
    }
    @picker = @$el.find '.picker'

  catch: ->
    @trigger 'catch'
    @pending = true
    @picker.addClass('active')

  uncatch: ->
    @pending = false
    @picker.removeClass('active')

  process: (e) ->
    return unless @pending
    code = @parse_code e
    if not code?
      @catch()
    else if code == '_'
      @uncatch()
    else
      @set code
      @render_codes()
      @uncatch()
      @save_codes()

  set: (code) ->
    @keys_repo.bind code, this
    @codes = [code].concat(
      if @codes.length < @max_len then @codes
      else _.initial @codes)

  unset: (code) ->
    @keys_repo.clear code
    @codes = _.filter @codes, (x) -> x != code
    @render_codes()

  parse_code: (e) ->
    code = e.keyCode || e.which
    char = String.fromCharCode(code).toUpperCase()
    switch true
      when e.ctrlKey            then 'CTRL'
      when e.shiftKey           then 'SHIFT'
      when e.altKey             then 'ALT'
      when code == 37           then 'LEFT'
      when code == 38           then 'UP'
      when code == 39           then 'RIGHT'
      when code == 40           then 'DOWN'
      when code == 9            then 'TAB'
      when code == 91           then 'SUPER'
      when char == ' '          then 'SPACE'
      when @allowed_chars(char) then char
      when code == 27           then '_'
      else undefined

  render_codes: ->
    text = _.map(@codes, @map_code).join ', '
    @picker.html if text == '' then ' --- ' else text

  set_codes: (codes) ->
    @keys_repo.clear x for x in @codes
    @codes = []
    @set x for x in codes
    @render_codes()

  to_default: ->
    @set_codes @default

  save_codes: ->
    data = {}
    data[@option] = @codes
    @trigger 'save', data

class MegaballWeb.Views.UserControlView extends MegaballWeb.Views.MasterView
  el: "#user_control_block"

  events:
    'click .close':'hide'
    'click .apply':'hide'
    'click .default':'to_default'

  initialize: (@current_user) ->
    super
    console.log("Initialization user control view")
    @pickers = {}
    @data = {}
    @controls = @$el.find '.controls'

    @keys_repo = new class
      constructor: -> @keys = {}
      bind: (key, pick) ->
        @keys[key].unset key if @in_use key
        @keys[key] = pick
      in_use: (key) -> @keys[key]?
      clear: (key) -> @keys[key] = undefined

    # init pickers
    @new_picker { keys_repo: @keys_repo, title: 'вверх', option: 'up', default: ['UP', 'W'] }
    @new_picker { keys_repo: @keys_repo, title: 'нитро', option: 'nitro', default: ['CTRL'] }
    @new_picker { keys_repo: @keys_repo, title: 'вниз', option: 'down', default: ['DOWN', 'S'] }
    @new_picker { keys_repo: @keys_repo, title: 'умение 1', option: 'skill1', default: ['Q'] }
    @new_picker { keys_repo: @keys_repo, title: 'влево', option: 'left', default: ['LEFT', 'A'] }
    @new_picker { keys_repo: @keys_repo, title: 'умение 2', option: 'skill2', default: ['E'] }
    @new_picker { keys_repo: @keys_repo, title: 'вправо', option: 'right', default: ['RIGHT', 'D'] }
    @new_picker { keys_repo: @keys_repo, title: 'умение 3', option: 'skill3', default: ['R'] }
    @new_picker { keys_repo: @keys_repo, title: 'удар', option: 'kick', default: ['SPACE'] }

  render: ->
    console.log("Render user control view")

  hide: ->
    @uncatch()
    @hide_modal()

  new_picker: (opts={}) ->
    opts.current_user = @current_user
    view = new MegaballWeb.Views.PickerView opts
    view.on 'catch', @context @uncatch
    view.on 'save', @context @save
    @controls.append view.$el
    @pickers[opts.option] = view

  uncatch: ->
    y.uncatch() for x, y of @pickers

  to_default: ->
    data = {}
    for x, y of @pickers
      y.to_default()
      data[y.option] = y.default
    @save data

  save: (data) ->
    @current_user.save {
      user_control: data
    }, {
      patch: true
    }
