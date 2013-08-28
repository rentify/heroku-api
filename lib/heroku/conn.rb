require 'json'
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
    _Request = Net::HTTP.const_get(method.capitalize)

    req      = _Request.new(end_point, headers(opts))
    req.body = opts[:body]

    check_response(method, end_point, @https.request(req))
  end

  private

  def self.check_response(method, end_point, res)
    key = "#{method.to_s.upcase} #{end_point}"

    case res
    when Net::HTTPOK          then @response_cache[key] = [res["ETag"], JSON.parse(res.body)]
    when Net::HTTPNotModified then @response_cache.fetch(key)
    when Net::HTTPPartialContent
      if res["Next-Range"]
        @response_cache[key] = begin
          list_head       = JSON.parse(res.body)
          etag, list_tail = self.send(method, end_point, range: res["Next-Range"])
          [etag, list_tail.unshift(*list_head)]
        end
      else
        @response_cache[key] = [res["ETag"], JSON.parse(res.body)]
      end
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

  def self.raise_exception(res)
    raise res.class::EXCEPTION_CLASS.new("#{status(res.code)}", nil)
  end

  def self.status(code)
    Hash[Net::HTTPResponse::CODE_TO_OBJ.map { |k, v| [k, v.to_s] }]
      .merge({ "429" => "Net::HTTPTooManyRequests" }) # Ruby 1.9.3 shiv
      .fetch(code, "Net::HTTPUnknownError")
  end

  def self.headers(opts = {})
    {
      "Accept"        => 'application/vnd.heroku+json; version=3',
      "Content-Type"  => 'application/json',
      "Authorization" => Heroku::Config.auth_token,
      "User-Agent"    => Heroku::Config::USER_AGENT
    }.merge({}.tap do |header|
      header["If-None-Match"] = opts[:etag]  if opts[:etag]
      header["Range"]         = opts[:range] if opts[:range]
    end)
  end
end
