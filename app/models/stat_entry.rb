class StatEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :event, type: String
  field :info, type: Hash
end
