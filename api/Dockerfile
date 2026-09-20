# ベースイメージはパッチバージョンまで固定する。
# `ruby:3.1` のような流動タグにすると、イメージ側の Ruby が勝手に上がって
# Gemfile の ruby 指定と食い違い、コンテナが起動しなくなる（2026-09 に発生）。
# bullseye 版は Debian のリポジトリが archive に移り apt が 404 になるため bookworm を使う。
FROM ruby:3.1.7-bookworm
ARG RUBYGEMS_VERSION=3.3.20

# WORKDIRは指定したディレクトリがなければ自動で作成する
WORKDIR /api
COPY Gemfile* /api/

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs mariadb-client

# Bundlerのversionが起因してエラーが発生するのを防いでいる (結構苦労した)
# 過去には問題なく動いていた環境で急に動かなくなった人もいたみたい
RUN gem update --system ${RUBYGEMS_VERSION} && \
    bundle install
COPY . /api

# rails特有のバグを避けるために必要
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
