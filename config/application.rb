require File.expand_path('../boot', __FILE__)

require "active_model/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Liff
  class Application < Rails::Application
    config.assets.paths << "#{Rails.root}/app/assets/css"
    config.assets.paths << "#{Rails.root}/app/assets/img"
    config.assets.paths << "#{Rails.root}/app/assets/jsc"
    config.assets.paths << "#{Rails.root}/app/assets/webfonts"

    config.compass.require 'susy'

    config.paths.add 'app/models/services', glob: '*.rb'
    config.autoload_paths += Dir["#{Rails.root}/app/models/services"]
    config.paths.add 'app/models/reports', glob: '*.rb'
    config.autoload_paths += Dir["#{Rails.root}/app/models/reports"]
    config.encoding = 'utf-8'

    config.action_controller.include_all_helpers = true
  end
end
