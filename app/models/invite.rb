class Invite
  include Mongoid::Document

  field :source, type: Integer
  field :destination, type: Integer
  field :text_hash, type: String
  field :date, type: DateTime
end
