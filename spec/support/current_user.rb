module CurrentUser
  def stub_user authorized = true
    if authorized
      new_user
      request.env['warden'].stub authenticate!: current_user
      controller.stub current_user: current_user
    else
      request.env['warden'].stub(:authenticate!).
        and_throw(:warden, {scope: :user})
      controller.stub current_user: nil
    end
  end

  def sign_in user
    @current_user = user
  end

  def new_user
    User.delete_all
    AcidUser.delete_all
    @current_user = User.create({
      email: "test@example.com", 
      name: "Test User",
      password: "empty_password",
      active: true
    })
  end

  def refresh_user
    @current_user = User.find(current_user.id)
  end

  def current_user
    @current_user
  end

  attr_accessor :params 
end

RSpec.configure do |config|
  config.include CurrentUser

  config.before :each do
    @current_user = nil
    self.params = {}
  end

  config.after :each do
    #User.delete_all
    #AcidUser.delete_all
  end
end
