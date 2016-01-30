class MegaballWeb.Views.FriendsView extends MegaballWeb.Views.MasterView
  friends_page_length: 5
  animation_speed: 1000
  tagName:'div'
  template: _.template $('#friends_template').html()
  attributes:
    class:'friends'

  events:
    'click .first':'first'
    'click .last':'last'
    'click .previous':'previous'
    'click .next':'next'

  initialize: (@uids, @current_user) ->
    super
    console.log("Initialization Frineds view")
    that = this

    @left_bound = 0
    @right_bound = 0

    @friends_collection = new MegaballWeb.Collections.FriendsCollection
    @render_friends_collection = new MegaballWeb.Collections.FriendsCollection
    @users = new MegaballWeb.Collections.UsersCollection
    window.users = @users
    window.friend_uids = []
    @friend_views = {}

    @users.on 'sync', @sort_uids, @
    @users.fetch data: { uids: @uids.join(','), source: window.social_service.friends_source() }

    @current_user.on 'sync', @sync_friend_count, @
    @current_user.fetch()

    @render_friends_collection.on 'reset', @render, @
    @bind('first_render', @first, this)
    @bind('next_render', @next, this)
    @bind('last_render', @last, this)
    @bind('previous_render', @previous, this)

    window.u_group_user_status = @context @on_user_status

  sync_friend_count: ->
    count = @current_user.get 'friends_count'
    if (count != @uids.length)
      @current_user.save {
        friends_count: @uids.length
      },
      patch: true

  on_user_status: (statuses) ->
    console.log 'user statuses', statuses, @friend_views
    for status in statuses
      view = @friend_views[Number(status[0])]
      if view?
        view.online = status[1]
        view.render()

  sort_uids: ->
    @uids = _.sortBy @uids, @context (n) ->
      model = @users.find((m) -> m.has_provider(n, window.social_service.friends_source()))
      return model.get_level() if model?
      0
    @uids = @uids.reverse()

    if @uids.length then @trigger('first_render')
    else @render()

  user_by_friend: (id) -> @users.find((m) -> m.has_provider(id,  window.social_service.friends_source()))

  render: (animate=true) ->
    console.log("Render Friends view")

    that = this

    unless @first_rendered
      @$el.html ''
      @$el.html @template({})

      $('#footer').html ''
      $('#footer').append @$el
      @friends_body = @$el.find '#friends_body'
      @friends_body.html ''

      @first_rendered = true

    friends_render_block = $(document.createElement('div'))
    friends_render_block.addClass 'friends_page'

    window.friend_uids = []
    @friend_views = {}
    @render_friends_collection.each @context (item) ->
      view = @render_item item
      user = @user_by_friend(item.get 'id')
      if user?
        id = user.get '_id'
        window.friend_uids.push id
        @friend_views[Number(id)] = view
      friends_render_block.append view.$el

    if @render_friends_collection.length < @friends_page_length
      for i in [1..(@friends_page_length - @render_friends_collection.length)]
        friends_render_block.append @render_item(null).$el

    previous_friends_page = @friends_body.find '.friends_page'

    if @current_page? and @current_page < @last_rendered_page
      @friends_body.prepend friends_render_block
      @friends_body.find('.friends_page').css 'left', '0px'
      @animation = true
      @friends_body.animate({left:'0px'}, @animation_speed, -> 
        previous_friends_page.remove()
        that.friends_body.css 'left', '-100%'
        friends_render_block.css 'left', '33.3%'
        that.animation = false
      )
    else
      @friends_body.append friends_render_block

      if @last_rendered_page?
        @animation = true
        @friends_body.animate({left:'-200%'}, @animation_speed, -> 
          previous_friends_page.remove()
          that.friends_body.css 'left', '-100%'
          that.animation = false
        )

    if @current_page <= 0 or !@current_page?
      @$el.find('.first, .previous').addClass('inactive')
    else
      @$el.find('.first, .previous').removeClass('inactive')

    if @current_page >= @get_last_page() or !@current_page?
      @$el.find('.last, .next').addClass('inactive')
    else
      @$el.find('.last, .next').removeClass('inactive')

    @last_rendered_page = @current_page

  first: ->
    console.log 'First call'

    return if @animation

    @paginate 0, 'first_render'

  next: ->
    console.log 'Next call'

    return if @animation

    new_page = 0

    if @uids.length

      new_page = @current_page + 1
      
      last_page = @get_last_page()

      if new_page > last_page
        new_page = last_page

    @paginate new_page, 'next_render'

  last: ->
    console.log 'Last call'

    return if @animation

    @paginate @get_last_page(), 'last_render'

  previous: ->
    console.log 'Previous call'

    return if @animation

    new_page = 0

    if @uids.length

      new_page = @current_page - 1
     
      if new_page < 0
        new_page = 0

    @paginate new_page, 'previous_render'

  add_in_collection: (data) ->
    unless @friends_collection.get data.id 
      @friends_collection.add [data]

  render_item: (friend) ->
    view_params = null

    if friend?
      id = friend.get 'id'
      view_params =
        model: friend
        user: @user_by_friend(id)
    
    view = new MegaballWeb.Views.FriendView view_params
    view

  download_users: (uids, callback) ->
    that = this

    window.social_service.download_users uids, @add_in_collection, callback, that

  paginate: (page, undefined_users_callback)->
    that = this

    if !@uids.length or (@current_page? and @current_page == page)
      return

    new_left_bound = page * @friends_page_length
    new_right_bound = new_left_bound + @friends_page_length - 1

    need_uids = @uids[new_left_bound..new_right_bound]
    download_uids = []
    render_models = []

    for uid in need_uids
      buf = @friends_collection.get uid

      if buf?
        render_models.push _.clone(buf.attributes)
      else
        download_uids.push uid

    if download_uids.length
      @download_users download_uids, -> that.trigger undefined_users_callback
      return

    @current_page = page

    @render_friends_collection.reset render_models 

  get_last_page: ->

    last_page = 0

    if @uids.length
      last_page = (parseInt (@uids.length / @friends_page_length) ) 

      if ! @uids.length % @friends_page_length
        last_page++

    last_page

