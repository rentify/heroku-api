require 'heroku/config'

class Heroku::API
  require 'heroku/api/account'

  extend Heroku::Config::ConfigMethods
  extend Heroku::API::Account

end
