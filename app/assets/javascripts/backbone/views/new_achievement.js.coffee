class MegaballWeb.Views.NewAchievementView extends MegaballWeb.Views.MasterView
  el: "#new_achievement_block"

  prise_template: _.template """
    {{ if (has_label) { }}
      <div class='prise-title'>{{=label}}</div>
    {{ } }}
    {{=value}}
  """

  events:
    'click .do-hide':'hide'
    'click .action':'action'

  prise_mapping:
    'experience': (item) -> @labelvalue {
      label: 'Опыт:'
      value: item
    }

    'coins': (item) -> @labelvalue {
      value: "<input type='button' class='icon price-coin-huge-icon' value='#{item}' />"
    }

    'stars': (item) -> @labelvalue {
      value: "<input type='button' class='icon price-star-huge-icon' value='#{item}' />"
    }

    'rating': (item) -> @labelvalue {
      label: 'Очки рейтинга:'
      value: item
    }

  labelvalue: (data) ->
    @prise_template _.extend data, {
      has_label: data.label?
    }

  initialize: (@refresh, @current_user) ->
    super
    console.log("Initialization new achievement view")
    @prise = @$el.find('.prise-holder')
    @icon = @$el.find('.ach img')
    @title = @$el.find('.title span')
    @action_btn = @$el.find('.action-text')

  navigated_modal: (@achievement) ->
    console.log @achievement
    prise = @achievement.prise
    keys = _.keys prise
    data = @prise_mapping[keys[0]].apply(this, [prise[keys[0]]])
    @prise.html data
    @icon.attr 'src', @achievement.picture
    @title.html @achievement.title
    @action_btn.html if window.social_service.can_wallpost() then 'на стену' else 'показать'

  render: ->

  hide: ->
    @hide_modal()

  action: ->
    if window.social_service.can_wallpost()
      window.social_service.wallpost(
        @current_user,
        window.social_service.ACHIEVEMENT[@achievement.unique_id],
        "Я получил достижение #{@achievement.title} в новой игре Megaball! #{window.socialL_service.game_link()}",
        @achievement.title)
    else
      @hide_modal "/progress/achievements/#{@achievement.title}"
