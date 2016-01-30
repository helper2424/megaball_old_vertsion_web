class ChatServer
  include Mongoid::Document

  field :address, type: String
  field :port, type: Integer
  field :exp_date, type: DateTime
  field :online, type: Integer, default: 0
  field :load, type: Float, default: 0.0
  
  attr_accessible :address, :port, :exp_date

  index({ "exp_date" => 1 }, {expire_after_seconds: 1})

  def as_json(options={})
    super :only => [:address, :port]
  end
end