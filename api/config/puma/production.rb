# socketの設定
bind "unix://#{Rails.root}/tmp/sockets/puma.sock"

# デーモン化（バックグラウンドでRailsを起動）
daemonize