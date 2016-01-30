class MegaballWeb.Views.Invite extends MegaballWeb.Views.MasterView
  el: 'body'

  events:
    'click .generate':'generate'

  initialize: ->
    super
    console.log("Initialization Invite view")
    @model = new MegaballWeb.Models.Invite

    @render
    

  generate: ->
    console.log 'Invite generate click'

    @model.save {},
      success: (model, data, context)-> 
        model.set "invite", data.invite
        alert model.get 'invite'

  render: ->
    console.log("Render Invite view")
