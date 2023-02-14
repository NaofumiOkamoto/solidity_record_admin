
require 'puma/daemon'   
bind "unix:#{Rails.root}/tmp/sockets/puma.sock"
workers 3
threads 2,3
daemonize