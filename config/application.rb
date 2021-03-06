require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module ItalyabroadNew
  class Application < Rails::Application
    config.autoload_paths += [config.root.join('lib')]
    config.assets.precompile += %w( site.js , chat.js, landing_layout.js)
    config.assets.precompile += %w( admin.js , admin.css , landing.css ,  private_pub.js, jquery_ujs.js )
    config.encoding = 'utf-8'
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  
    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{RAILS_ROOT}/extras )
  
    # Specify gems that this application depends on and have them installed with rake gems:install
    # config.gem "bj"
    # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
    # config.gem "sqlite3-ruby", :lib => "sqlite3"
  
    # config.gem "aws-s3", :lib => "aws/s3"
    # config.gem "rmagick"
   #  config.gem "xml-simple", :version => '1.0.12'
    # config.gem " mime-types"

    config.cache_classes = true
    config.consider_all_requests_local       = false
    config.action_controller.perform_caching = true
    config.serve_static_assets = true
    config.static_cache_control = "public, max-age=3600"
    config.assets.compress = false
    config.assets.compile = false
    config.assets.digest = true


    config.gem 'prawn'
    config.gem "activemerchant", :version => ">= 1.5.1", :lib => "active_merchant"
    config.gem 'will_paginate', :version => '>= 2.3.12'
    config.gem "RedCloth"
    config.gem "pdfkit"
  
    config.gem 'rails'
    config.gem "mysql2"
    config.gem 'simple_captcha'

    config.gem "capistrano" 
    #config.gem "capistrano-ext"
    config.middleware.use "PDFKit::Middleware"
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  
    # Skip frameworks you're not going to use. To use Rails without a database,
    # you must remove the Active Record framework.
    # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  
    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names.
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc
    config.middleware.use PDFKit::Middleware
  
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :de
  
    # This line added by Sujith since we believe httponly is a problem while redirecting to HTTPS in checkout/payment page
    # config.action_controller.session = { :httponly => false }
    config.session_store(:httponly => false)
    #config.action_dispatch.ignore_accept_header = true
     # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end
require "custom_country_select"
require 'simple_captcha'
require 'carrierwave/orm/activerecord'
ActiveRecord::Base.logger = Logger.new STDOUT

