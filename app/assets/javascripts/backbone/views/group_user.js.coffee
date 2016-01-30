class MegaballWeb.Views.GroupUserView extends MegaballWeb.Views.MasterView

  template: _.template $('#group_user_template').html()

  events:
    "click input":"remove_from_group"
  
  initialize: (@current_user, @show_remove)->
    super
    console.log("Initialization Group user view")
    @render()

  render: ->
    console.log("Render Group user view")
    json_data = @current_user.toJSON()
    json_data['show_remove'] = @show_remove
    @$el.html @template json_data

  remove_from_group: ->
    window.u_group_action 6, [@current_user.get('_id')]
