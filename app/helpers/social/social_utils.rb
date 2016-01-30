class SocialUtils
  @@instance = nil

  def notify(msg)
  end

  def self.empty
    @@instance = SocialUtils.new if @@instance.nil?
    @@instance
  end
end
