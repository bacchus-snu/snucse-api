FROM phusion/passenger-full:1.0.0
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
