class ClubUserRequest
  include Mongoid::Document

  field :uid, type: Integer
  field :cid, type: Integer
  field :requested_at, type: Time, default: ->{ Time.now }

  index({ requested_at: 1 }, { expire_after_seconds: 3.days })

  validates :uid, presence: true
  validates :cid, presence: true
  
  validate :request_count
  validate :club_presence
  validate :request_uniqueness

  index :uid => 1, :cid => 1
  index :cid => 1

  def club_presence
    if Club.where(id: self.cid).count == 0
      errors.add :cid, "Club doesn't exist"
    end
  end

  def request_uniqueness
    if ClubUserRequest.where(uid: self.uid, cid: self.cid).count > 0
      errors.add :uid, "already_sent"
    end
  end

  def request_count
    if ClubUserRequest.where(uid: self.uid).count >=
        UserDefault.first.max_club_requests
      errors.add :uid, "exceeded"
    end
  end
end
