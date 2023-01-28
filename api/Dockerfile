FROM ruby:3.1
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
