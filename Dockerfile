FROM ruby:3.4-slim AS build

ENV BUNDLE_DEPLOYMENT=1 \
    BUNDLE_WITHOUT=development:test \
    RAILS_ENV=production

WORKDIR /app

RUN apt-get update \
    && apt-get install --no-install-recommends -y build-essential default-libmysqlclient-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install \
    && rm -rf /usr/local/bundle/cache

FROM ruby:3.4-slim

ENV BUNDLE_DEPLOYMENT=1 \
    BUNDLE_WITHOUT=development:test \
    RAILS_ENV=production

WORKDIR /app

RUN apt-get update \
    && apt-get install --no-install-recommends -y imagemagick libmariadb3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/vendor/bundle /app/vendor/bundle

COPY . .

RUN groupadd --gid 10001 snucse \
    && useradd --uid 10000 --gid 10001 --create-home snucse \
    && chown -R snucse:snucse /app

USER snucse

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
