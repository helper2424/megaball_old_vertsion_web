class MegaballWeb.Views.Helpers.ClubRoleManager

  apply_restrictions: (role) ->
    for restr in @restrictions
      @$el.find(restr.inactivate).removeClass('inactive')
      @$el.find(restr.hide).show()
    for i, restr of @restrictions when i >= role
      @$el.find(restr.hide).hide() if restr.hide?
      @$el.find(restr.inactivate).addClass('inactive') if restr.inactivate?
