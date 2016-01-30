# Puma web server config

app_dir = "/home/r3studio/megaball_web"
app_dir = "/home/helper/external_disk/myProjects/megaball_web" if ENV['RAILS_ENV'] == 'development'
app_dir = "/home/development/megaball_web" if ENV['RAILS_ENV'] == 'production'
app_dir += "/"

directory app_dir

threads 50,500
workers 6

preload_app!

pidfile "#{app_dir}tmp/pids/puma.pid"
state_path "#{app_dir}tmp/pids/puma.state"

stdout_redirect "#{app_dir}log/puma.stdout.log", "#{app_dir}log/puma.stderr.log", true

if ENV['RAILS_ENV'] == "development"
  bind 'tcp://0.0.0.0:3000'
else
  bind "unix://#{app_dir}tmp/sockets/megaball_web.socket"
end

on_worker_boot do
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.


end