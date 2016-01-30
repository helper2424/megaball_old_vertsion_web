class ClubUser
  include Mongoid::Document

  field :uid, type: Integer
  field :cid, type: Integer

  field :place_in_club, type: Integer, default: 0
  field :rating_arrow, type: Integer, default: 1
  # 1  - up
  # 0  - no arrow
  # -1 - down
  
  field :role, type: Integer, default: 0
  # 0 - regular user
  # 1 - moderator
  # 2 - administrator
  
  index :uid => 1, :cid => 1
  index :cid => 1

  validates :uid, presence: true
  validates :cid, presence: true

  def moderator?; self.role >= 1; end
  def administrator?; self.role >= 2; end
end
