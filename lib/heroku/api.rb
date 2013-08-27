require 'heroku/config'

class Heroku::API
  require 'heroku/api/account'
  require 'heroku/api/password'

  extend Heroku::Config::ConfigMethods
  extend Heroku::API::Account
  extend Heroku::API::Password

end
