require 'net/http'
require 'heroku/config'

class Heroku::Conn
  BadRequestError      = Class.new(StandardError)
  UnauthorizedError    = Class.new(StandardError)
  PaymentRequiredError = Class.new(StandardError)
  ForbiddenError       = Class.new(StandardError)
  NotFoundError        = Class.new(StandardError)
  NotAcceptableError   = Class.new(StandardError)
  RateLimitError       = Class.new(StandardError)

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

    check_response(end_point, @https.request(req))
  end

private

  def self.check_response(end_point, res)
    case res
    when Net::HTTPOK          then @response_cache[end_point] = res
    when Net::HTTPNotModified then @response_cache.fetch(end_point)
    when Net::HTTPSuccess     then res

    when Net::HTTPBadRequest                   then raise BadRequestError
    when Net::HTTPUnauthorized                 then raise UnauthorizedError
    when Net::HTTPPaymentRequired              then raise PaymentRequiredError
    when Net::HTTPForbidden                    then raise ForbiddenError
    when Net::HTTPNotFound                     then raise NotFoundError
    when Net::HTTPNotAcceptable                then raise NotAcceptableError
    when Net::HTTPRequestedRangeNotSatisfiable then raise RangeError
    else
      raise RateLimitError if res.code == "429" # Ruby 1.9.3 has no Net::HTTPTooManyRequests class.
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
