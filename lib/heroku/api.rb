require 'heroku/config'

module Heroku
  class API
    require 'heroku/api/account'
    require 'heroku/api/password'
    require 'heroku/api/rate_limits'
    require 'heroku/api/regions'
    require 'heroku/api/apps'
    require 'heroku/api/app'

    extend Heroku::Config::ConfigMethods
    extend Heroku::API::Account
    extend Heroku::API::Password
    extend Heroku::API::RateLimits
    extend Heroku::API::Regions
    extend Heroku::API::Apps
  end
end
