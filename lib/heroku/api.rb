require 'heroku/config'
require 'heroku/api/account'

class Heroku::API
  extend Heroku::Config::ConfigMethods

  include Heroku::API::Account
end
