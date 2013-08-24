require 'heroku/config'

class Heroku::API
  require 'heroku/api/account'

  extend Heroku::Config::ConfigMethods

  include Heroku::API::Account
end
