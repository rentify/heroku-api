require 'net/http'
require 'heroku/config'

class Heroku::Conn
  @https = Net::HTTP.new('api.heroku.com', 443).tap do |https|
    https.use_ssl     = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  @response_cache = {}

  def self.method_missing(method, end_point, opts = {})
    _Request    = Net::HTTP.const_get(method.capitalize)

    header_hash = headers(opts[:etag] ? { "If-None-Match" => opts[:etag] } : nil)

    req         = _Request.new(end_point, header_hash)
    req.body    = opts[:body]

    check_response(@https.request(req))
  end

private

  def self.check_response(res)
    case res
    when Net::HTTPOK
      @response_cache[res["ETag"]] = res if res["ETag"]
      res
    when Net::HTTPNotModified
      @response_cache.fetch(res["ETag"])
    end
  end

  def self.headers(additional = nil)
    {
      "Accept"        => 'application/vnd.heroku+json; version=3',
      "Authorization" => Heroku::Config.auth_token,
      "User-Agent"    => Heroku::Config::USER_AGENT
    }.merge(additional || {})
  end
end
