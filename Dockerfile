FROM phusion/passenger-full:1.0.0
RUN apt-get update && apt-get install -y libmysqlclient-dev libmysqlclient20 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install
RUN apt update && apt install imagemagick -y && rm -rf /var/lib/apt/lists/*
COPY . .
RUN useradd -ms /bin/bash snucse
RUN chown -R snucse: /app
USER snucse
CMD ["passenger", "start"]
