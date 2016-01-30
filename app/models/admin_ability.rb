class AdminAbility
  include CanCan::Ability

  def initialize(user)
    if user && user.admin
      I18n.locale = user.locale.to_sym
      can :access, :rails_admin
      can :manage, :all   
    end
  end
end
