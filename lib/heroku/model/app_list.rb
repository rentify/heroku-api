require 'heroku/model'
require 'heroku/api'

class Heroku::Model::AppList < Heroku::Model::ArrayProxy
  include Heroku::API::App

  def inspect
    "#<Heroku::Model::Apps>"
  end

  def [](key)
    case key
    when String, Symbol then app(key.to_s)
    else                     super(key)
    end
  end
end
