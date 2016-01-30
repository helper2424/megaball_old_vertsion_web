class EnergyRequest
  include Mongoid::Document

  before_validation :gen_unique_id

  belongs_to :friend, class_name: 'User', inverse_of: :energy_request_friend, index: true
  belongs_to :receiver, class_name: 'User', inverse_of: :energy_request_receiver, index: true

  field :unique_id, type: String

  validates :friend, { presence: true }
  validates :receiver, { presence: true }

  validates :unique_id, {
    presence: true,
    uniqueness: { case_sensitive: false }
  }

  private
  
  def gen_unique_id
    self.unique_id = "#{self.receiver_id}_#{self.friend_id}"
  end
end
