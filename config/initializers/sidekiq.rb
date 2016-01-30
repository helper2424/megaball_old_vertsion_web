Sidekiq.configure_server do |config|
  config.redis = { :url => 'redis://127.0.0.1:6379/13', :namespace => 'megaball_space' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => 'redis://127.0.0.1:6379/13', :namespace => 'megaball_space' }
end
