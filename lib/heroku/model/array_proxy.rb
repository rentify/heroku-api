class Heroku::Model::ArrayProxy
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

protected

  def proxy_array
    @proxy_array ||= @deferred_array.call(self)
  end
end
