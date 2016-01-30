class MegaballWeb.Views.SkillView extends MegaballWeb.Views.MasterView
  tagName:'div'
  template: _.template $('#skill_template').html()


  initialize: ->
    super
    #console.log 'Initializing skill view'
    @model = @options.model
    @render()

  render: ->
    @$el.html ''

    if @model?
      @texture = @model.texture
      @charge = if @model.charge > 99 then 99 else @model.charge
      @$el.append $ @template {
        texture: @texture
        charge: @charge
        active: @model.active
      }
    else
      @$el.append $ @template {
        texture: false
        charge: false
        active: false
      }
