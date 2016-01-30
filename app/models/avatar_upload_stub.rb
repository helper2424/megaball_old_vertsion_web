class AvatarUploadStub
  include Mongoid::Document
  include Mongoid::Paperclip

  before_create :randomize_file_name

  # images
  has_mongoid_attached_file :photo, 
    storage: :fog,
    path: "temp/avatars/:filename",
    url: "temp/avatars/:filename"

  def randomize_file_name
    return if photo_file_name.nil?
    stamp = "#{(Time.now.to_f * 1000).round.to_s}_"

    extension = File.extname(photo_file_name).downcase
    self.photo.instance_write(:file_name, "#{stamp}#{self._id}#{extension}")
  end
end