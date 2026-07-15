require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Snucse
  class Application < Rails::Application
    config.load_defaults 7.2
    config.active_record.belongs_to_required_by_default = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.time_zone = 'Seoul'

    Jbuilder.key_format camelize: :lower

    CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/
  end
end

require 'carrierwave/orm/activerecord'
