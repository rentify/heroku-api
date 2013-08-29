require 'json'
require 'net/http'
require 'heroku/config'

class Heroku::Conn

  APIRequest = Struct.new(:method, :end_point)
  CachePair  = Struct.new(:response, :etag)

  @https = Net::HTTP.new('api.heroku.com', 443).tap do |https|
    https.use_ssl     = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  @response_cache = {}
  @etag_pointers  = {}

  def self.method_missing(method, end_point, opts = {})
    _Request = Net::HTTP.const_get(method.capitalize)

    req      = _Request.new(end_point, headers(opts))
    req.body = opts[:body]
    api_req  = APIRequest[method, end_point]

    cache_pair = CachePair[
      @response_cache[opts[:r_type]] ||= {},
      @etag_pointers[opts[:r_type]]  ||= {}
    ]

    check_response(api_req, cache_pair, @https.request(req))
  end

  private

  def self.check_response(api_req, cache_pair, res)
    case res
    when Net::HTTPOK, Net::HTTPCreated then cache_response(cache_pair, res)
    when Net::HTTPPartialContent       then cache_and_gather_partial_response(api_req, cache_pair, res)
    when Net::HTTPNotModified          then fetch_response(cache_pair, res)
    when Net::HTTPSuccess              then res
    else                                    raise_exception(res)
    end
  end

  def self.cache_key(json)
    case json
    when Array then "list"
    when Hash  then  json['id']
    else             nil
    end
  end

  def self.update_cache_pair(cache_pair, json, new_etag)
    key          = cache_key(json)
    old_etag, _  = cache_pair.response[key]
    cache_record = [new_etag, json]

    cache_pair.etag.delete(old_etag)
    cache_pair.response[key]  = cache_record
    cache_pair.etag[new_etag] = cache_record
  end

  def self.cache_response(cache_pair, res)
    update_cache_pair(cache_pair, JSON.parse(res.body), res["ETag"])
  end

  def self.cache_and_gather_partial_response(api_req, cache_pair, res)
    if res["Next-Range"]
      list_head       = JSON.parse(res.body)
      etag, list_tail =
        self.send(
          api_req.method,
          api_req.end_point,
          range: res["Next-Range"]
        )

      update_cache_pair(cache_pair, list_tail.unshift(*list_head), etag)
    else
      cache_response(cache_pair, old_etag, res)
    end
  end

  def self.fetch_response(cache_pair, res)
    cache_pair.etag[res["ETag"]]
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
