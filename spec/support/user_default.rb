RSpec.configure do |config|
  config.before :each do UserDefault.create end
  config.after :each do UserDefault.delete_all end
end
