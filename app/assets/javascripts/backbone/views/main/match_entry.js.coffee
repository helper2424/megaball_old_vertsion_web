class MegaballWeb.Views.MatchEntryView extends MegaballWeb.Views.MasterView
  template: _.template $("#match_entry_template").html()

  initialize: ->
    @model = @options.model
    @game_plays = @options.game_plays
    @render()

  format_time: (sec) ->
    parseInt(sec/60)+":"+parseInt((sec%60)/10)+""+(sec%10)

  render: ->
    @$el = $ @template _.extend @model.toJSON(), {
      game_play_title: @game_plays[@model.get 'game_play']
      time_left: @format_time(@model.get('time_left'))
    }
