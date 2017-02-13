require 'rails'
require_relative 'boot'

#require 'rails/all' # Commenting out to disable ActiveRecord

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# important that this is imported after gems in Gemfile are imported
%w(
  mongoid
  action_controller
  action_mailer
  active_resource
  rails/test_unit
).each do |framework|
begin
  require "#{framework}/railtie"
    rescue LoadError
  end
end

module Qwkio
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
