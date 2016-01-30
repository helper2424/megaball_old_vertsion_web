class UserControl
	include Mongoid::Document

  auto_increment :_id, :seed  => 0

  field :up, type: Array, default: ['UP', 'W']
  field :down, type: Array, default: ['DOWN', 'S']
  field :left, type: Array, default: ['LEFT', 'A']
  field :right, type: Array, default: ['RIGHT', 'D']

  field :kick, type: Array, default: ['SPACE']

  field :skill1, type: Array, default: ['Q']
  field :skill2, type: Array, default: ['E']
  field :skill3, type: Array, default: ['R']
  field :skill4, type: Array, default: ['T']

  field :nitro, type: Array, default: ['CTRL']

  embedded_in :user

  def from_hash(hash={})
    return if hash.nil?
    %w(up down left right kick skill1 skill2 skill3 skill4 nitro).each do |x|
      if hash.include? x
        val = hash[x][0..2].map { |s| s.to_s }
        self.send("#{x}=".to_sym, val)
      end
    end
  end
end
