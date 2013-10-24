require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# # require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Pagpos
  class Application < Rails::Application

    # don't generate RSpec tests for views and helpers
    config.generators do |g|
      
      g.test_framework :rspec, fixture: true
      
      
      g.fixture_replacement :fabrication
      g.view_specs false
      g.helper_specs false
    end

    config.generators.assets = false
    config.generators.helper = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # config.assets.precompile += %w( application.js zepto.js custom.modernizr.js foundation.abide.js foundation.alert.js foundation.clearing.js foundation.cookie.js foundation.dropdown.js foundation.form.js foundation.interchange.js foundation.joyride.js foundation.js foundation.magellan.js foundation.orbit.js foundation.placeholder.js foundation.reveal.js foundation.section.js foundation.tooltip.js foundation.toolbar.js jquery_ujs.js index.js jquery.js turbolinks.js html5.js application.css foundation_and_overrides.scss _setting.scss accessibility_foundicons.scss accessibility_foundicons_ie7.scss general_foundicons.scss general_foundicons_ie7.scss social_founditions.scss social_founditions_ie7.scss general_enclosed_founditions.scss general_enclosed_founditions_ie7.scss style.scss LigatureSymbols-2.07.eot LigatureSymbols-2.07.svg LigatureSymbols-2.07.ttf LigatureSymbols-2.07.woff accessibility_foundicons.eot accessibility_foundicons.svg accessibility_foundicons.ttf accessibility_foundicons.woff general_foundicons.eot general_foundicons.svg general_foundicons.ttf general_foundicons.woff general_enclosed_founditions.eot general_enclosed_founditions.svg general_enclosed_founditions.ttf general_enclosed_founditions.woff social_founditions.eot social_founditions.ttf social_founditions.svg social_founditions.woff)
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif fontawesome-webfont.ttf fontawesome-webfont.eot fontawesome-webfont.svg fontawesome-webfont.woff LigatureSymbols-2.07.eot LigatureSymbols-2.07.svg LigatureSymbols-2.07.ttf LigatureSymbols-2.07.woff accessibility_foundicons.eot accessibility_foundicons.svg accessibility_foundicons.ttf accessibility_foundicons.woff general_foundicons.eot general_foundicons.svg general_foundicons.ttf general_foundicons.woff general_enclosed_founditions.eot general_enclosed_founditions.svg general_enclosed_founditions.ttf general_enclosed_founditions.woff social_founditions.eot social_founditions.ttf social_founditions.svg social_founditions.woff)

    config.assets.precompile << Proc.new do |path|
      if path =~ /\.(css|js)\z/
        full_path = Rails.application.assets.resolve(path).to_path
        app_assets_path = Rails.root.join('app', 'assets').to_path
        if full_path.starts_with? app_assets_path
          puts "including asset: " + full_path
          true
        else
          puts "excluding asset: " + full_path
          false
        end
      else
        false
      end
    end
  end
end
