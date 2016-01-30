module MongoidControl
  def teardown!
    Mongoid.purge!
  end
end

RSpec.configure do |config|
  config.include Mongoid::Matchers
  config.include MongoidControl
end
