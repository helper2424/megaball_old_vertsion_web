class MegaballWeb.Views.UserPictureView extends MegaballWeb.Views.MasterView
  tagName: 'div'
  template: _.template $('#userpicture_template').html()
  
  parts: ['hair', 'eye', 'mouth']

  initialize: ->
    super
    console.log("Initialization user picture view")
    @need_to_redraw = true
    @params =
      hair: @default 'hair', 1
      eye: @default 'eye', 1
      mouth: @default 'mouth', 1
      small: false
      platform: @options.platform ? 'normal'
      only: undefined
    
    @render() unless @options.dont_render == true

  update_zorder: ->
     if @raw_params?
        console.log(@raw_params)

        hair_only = window.user_default.hair_only.indexOf(@raw_params.hair) != -1
        hair_top = window.user_default.hair_top.indexOf(@raw_params.hair) != -1
        scarf = window.user_default.scarf.indexOf(@raw_params.mouth) != -1

        if hair_top
          @$el.find(".parts.hair").css("z-index",4)
        else
          @$el.find(".parts.hair").css("z-index",2)
        
        if hair_only
          if scarf
            @$el.find(".parts.mouth").show()
          else
            @$el.find(".parts.mouth").hide()
          @$el.find(".parts.eye").hide()
        else
          @$el.find(".parts.mouth").show()
          @$el.find(".parts.eye").show()

        
        console.log("hair_top="+hair_top+", hair_only="+hair_only+", scarf="+scarf)
      else
        console.log("No h.y.m. params!")
    
  render: ->
    if @need_to_redraw

      @$el.html ''
      @$el.append $ @template @params

      if @params.only?
        @$el.find(".parts").hide()
        @$el.find(".#{x}").show() for x in @params.only

    @update_zorder()

  set_raw_params: (params) ->
    @raw_params = params

  set_raw_param: (type,param) ->
    @raw_params[type] = param
    
  _set_params: (params) ->
    @need_to_redraw = false
    for k, v of @params when params[k]? and params[k] != @params[k]
      @params[k] = params[k]
      @need_to_redraw = true

  set_params: (params={}) ->
    @_set_params params
    @render()

  animate: (params={}, {callback}) =>
    @_set_params params
    if @need_to_redraw
      @$el.fadeOut 100, =>
        @render()
        @$el.fadeIn 100, =>
          callback() if callback?

  default: (type, id) -> "#{window.assetRootPath}/user/#{type}/#{id}.png"

  from_user: (user) ->
    @raw_params = {
      hair: user.hair ? user.get 'hair'
      eye: user.eye ? user.get 'eye'
      mouth: user.mouth ? user.get 'mouth'
    }

    @set_params {
      hair:  @default 'hair', (user.hair ? user.get 'hair')
      eye:  @default 'eye',  (user.eye ? user.get 'eye')
      mouth: @default 'mouth', (user.mouth ? user.get 'mouth')
    }

  to_html: ->
    temp = $ '<div/>'
    temp.append @$el.clone()
    temp.html()
