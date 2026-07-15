source 'https://rubygems.org'

gem 'rails', '~> 7.2.3', '>= 7.2.3.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 2.7'
gem 'mysql2', '~> 0.5'
# Use Puma as the app server
gem 'puma', '~> 7.2', '>= 7.2.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.14'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 5.4'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1', '>= 3.1.22'

gem 'tzinfo-data', '~> 1.2025'

# Use Capistrano for deployment
gem 'capistrano-rails'
gem 'capistrano-rbenv'

gem 'kaminari'
# The deployed search cluster is Elasticsearch 2.x.
gem 'elasticsearch', '~> 5.0'
gem 'elasticsearch-model', '~> 0.1.9'
gem 'faraday', '~> 1.10', '>= 1.10.6'

gem 'carrierwave', '~> 3.1', '>= 3.1.3'
gem 'mini_magick', '~> 5.3'

gem 'redcarpet', '~> 3.6'

gem 'apipie-rails', '~> 1.5'

group :development, :test do
  gem 'debug', platforms: :mri
end

group :test do
  gem 'mock_redis', '~> 0.55'
end

group :development do
  gem 'listen', '~> 3.9'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1'
end
