# -*- encoding: utf-8 -*-
#
class Club
	include Mongoid::Document
  include Mongoid::Search
  include Mongoid::Paperclip

  before_create :randomize_file_name
  #before_update :randomize_file_name

  before_save :update_level_info
  after_create :create_acid

  # identifier
  auto_increment :_id, seed: 1

  # names
  field :short_name, type: String
  field :zone, type: String, default: 'russian'
  field :name, type: String
  field :status_message, type: String, default: 'Добро пожаловать в клуб!' 

  # users
  field :creator_id, type: Integer
  field :max_players, type: Integer, default: 0

  # ratings
  field :rating, type: Integer, default: 0
  field :level, type: Integer, default: 1
  field :last_updated, type: Integer, default: 0

  # images
  has_mongoid_attached_file :_logo_remote, 
    styles: {
      original: ['200x200#', :jpg],
      preview: ['50x50#', :jpg],
    }, 
    storage: :fog,
    path: "clubs/logos/:style/:filename",
    url: "clubs/logos/:style/:filename"
  validates_attachment_content_type :_logo_remote, :content_type => ["image/jpg", "image/jpeg", "image/png"]

  has_mongoid_attached_file :_logo_local, 
    styles: {
      original: ['200x200#', :jpg],
      preview: ['50x50#', :jpg],
    },
    url: "/clubs/logos/:style/:filename"
    #path: "clubs/logos/:style/:filename"
  validates_attachment_content_type :_logo_local, :content_type => ["image/jpg", "image/jpeg", "image/png"]

  def logo=(val)
    return if self._logo_local == val or self._logo_remote == val
    self._logo_remote = val
    self._logo_local = val
    randomize_file_name
  end

  def logo
    (self._logo_remote?) ? self._logo_remote.path : self._logo_local.url
  end

  def logo?
    (self._logo_remote? and self._logo_remote.file?) or (self._logo_local? and self._logo_local.path?)
  end

  # dates
  field :created_at, type: Time, default: ->{ Time.now }
  field :ratings_update, type: Time, default: ->{ Time.now }

  # currencies
  field :coins, type: Integer, default: 0
  field :stars, type: Integer, default: 0

  search_in :short_name, :name

  # Scopes
  scope :for_zone, ->(zone) { where(zone: zone) }

  # Indexes
  index id: 1, zone: 1
  index zone: 1, rating: 1
  index zone: 1, last_updated: 1
  index rating: 1, zone: 1, last_updated: 1
  index id: 1, zone: 1, name: 1
  index id: 1, zone: 1, short_name: 1
  index({ zone: 1, short_name: 1 }, { unique: true })
  index({ zone: 1, name: 1 }, { unique: true })

  # Validations

  validates :short_name, {
    presence: true, 
    length: { minimum: 2, maximum: 4 }
  }

  validates :name, {
    presence: true,
    length: { minimum: 4, maximum: MEGABALL_CONFIG['club_defaults']['name_max_length'] }
  }

  validate :name_uniqueness_validator, before: :save

  def name_uniqueness_validator
    i = 0
    i += Club.where(:_id.ne => self.id, :zone => self.zone, :short_name => self.short_name).count
    i += Club.where(:_id.ne => self.id, :zone => self.zone, :name => self.name).count
    errors.add(:already_exists, I18n.t('club_already_exists')) if i > 0
  end

  # Methods

  def acid
    AcidClub.find(self._id)
  end

  def max_players
    level_info['max_players']
  end

  def as_json(opts={})
    exceptions = ['content_type', 'file_name', 'file_size', 'updated_at']
    json = super(except: exceptions.map { |x| "_logo_local_#{x}".to_sym } +
                         exceptions.map { |x| "_logo_remote_#{x}".to_sym } +
                         exceptions.map { |x| "logo_#{x}".to_sym } +
                         [:logo, :_logo_local, :_logo_remote, :_keywords] )
    json[:logo] = self.logo if self.logo?
    json[:members_count] = ClubUser.where(cid: self._id).count
    json[:request_count] = ClubUserRequest.where(cid: self._id).count
    json[:level_info] = self.level_info
    json[:place] = Club.where(:rating.gt => self.rating).count + 1 unless opts[:noplace]
    json
  end

  def level_info
    levels = MEGABALL_CONFIG['club_levels']
    i = levels.index { |x| x['from'] > self.level }
    i ||= levels.size
    levels[i-1]
  end

  def recalc_ratings
    club_users = Hash[ClubUser.where(cid: self._id).map{ |x| [x.uid, x] }]

    users = User
      .where(:_id.in => club_users.keys)
      .order_by([:rating, :desc])
      .to_a

    users.each_with_index do |u, i| 
      user = club_users[u._id]
      new_place = i + 1
      rating_arrow = user.place_in_club <=> new_place
      user.rating_arrow = rating_arrow if rating_arrow != 0
      user.place_in_club = new_place
      user.save!
    end

    self.rating = users.inject(0){ |x, y| x + y.rating }
    self.last_updated = Time.now.to_i
  end

  private

  def update_level_info
    self.max_players = level_info['max_players']
  end

  def create_acid
    AcidClub.create id: self._id, real_balance: 0, imagine_balance: 0
  end

  def randomize_file_name
    return if _logo_remote_file_name.nil? or _logo_local_file_name.nil?
    stamp = "#{(Time.now.to_f * 1000).round.to_s}_"

    extension = File.extname(_logo_remote_file_name).downcase
    self._logo_remote.instance_write(:file_name, "#{stamp}#{self._id}#{extension}")

    extension = File.extname(_logo_local_file_name).downcase
    self._logo_local.instance_write(:file_name, "#{stamp}#{self._id}#{extension}")
  end
end
