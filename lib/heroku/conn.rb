require 'net/http'
require 'heroku/config'

class Heroku::Conn
  @https = Net::HTTP.new('api.heroku.com', 443).tap do |https|
    https.use_ssl     = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def self.method_missing(method, end_point, body=nil)
    _Request = Net::HTTP.const_get(method.capitalize)
    req      = _Request.new(end_point, headers)
    req.body = body

    @https.request(req)
  end

  def self.headers
    {
      "Accept"        => 'application/vnd.heroku+json; version=3',
      "Authorization" => Heroku::Config.auth_token,
      "User-Agent"    => Heroku::Config::USER_AGENT
    }
  end
end
