require 'heroku/api'

class Heroku::Model::AppList
  include Heroku::API::App

  def inspect
    "#<Heroku::Model::Apps>"
  end

  def initialize(deferred_array)
    @deferred_array = deferred_array
  end

  def method_missing(sym, *args)
    begin
      proxy_array.send(sym, *args)
    rescue NoMethodError
      super
    end
  end

  def all
    proxy_array
  end

private

  def proxy_array
    @proxy_array ||= @deferred_array.call(self)
  end
end
