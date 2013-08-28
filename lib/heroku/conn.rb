require 'json'
require 'net/http'
require 'heroku/config'

class Heroku::Conn
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
    when Net::HTTPOK             then cache_response(method, end_point, res)
    when Net::HTTPPartialContent then cache_and_gather_partial_response(method, end_point, res)
    when Net::HTTPNotModified    then fetch_response(method, end_point)
    when Net::HTTPSuccess        then res
    else                              raise_exception(res)
    end
  end

  def self.key(method, end_point)
    "#{method.to_s.capitalize} #{end_point}"
  end

  def self.cache_response(method, end_point, res)
    @response_cache[key(method, end_point)] = [res["ETag"], JSON.parse(res.body)]
  end

  def self.cache_and_gather_partial_response(method, end_point, res)
    if res["Next-Range"]
      list_head       = JSON.parse(res.body)
      etag, list_tail = self.send(method, end_point, range: res["Next-Range"])

      @response_cache[key(method, end_point)] = [etag, list_tail.unshift(*list_head)]
    else
      cache_response(key(method, end_point), res)
    end
  end

  def self.fetch_response(method, end_point)
    @response_cache.fetch(key(method, end_point))
  end

  def self.raise_exception(res)
    raise res.class::EXCEPTION_TYPE.new(status(res.code), nil)
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
