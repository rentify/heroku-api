require 'heroku/config'

class Heroku::API
  require 'heroku/api/account'
  require 'heroku/api/password'
  require 'heroku/api/rate_limits'

  extend Heroku::Config::ConfigMethods
  extend Heroku::API::Account
  extend Heroku::API::Password
  extend Heroku::API::RateLimits

end
