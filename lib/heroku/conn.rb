require 'json'
require 'net/http'
require 'heroku/properties'

module Heroku
  class Conn
    require 'heroku/conn/cache'

    APIRequest = Struct.new(:method, :end_point)

    @https = Net::HTTP.new('api.heroku.com', 443).tap do |https|
      https.use_ssl = true
    end

    def self.cache
      @cache ||= Heroku::Conn::Cache.new
    end

    def self.method_missing(method, end_point, opts = {})
      _Request = Net::HTTP.const_get(method.capitalize)

      req      = _Request.new(end_point, headers(opts))
      req.body = opts[:body]
      api_req  = APIRequest[method, end_point]

      check_response(api_req, opts[:r_type], @https.request(req))
    end

  private

    def self.check_response(api_req, r_type, res)
      case res
      when Net::HTTPOK, Net::HTTPCreated then
        cache.put(
          r_type, res["ETag"],
          JSON.parse(res.body)
        )
      when Net::HTTPPartialContent       then
        cache.put(
          r_type, res["ETag"],
          gather_partial_content(api_req, res)
        )
      when Net::HTTPNotModified          then cache.fetch(r_type, res["ETag"])
      when Net::HTTPSuccess              then res
      else                                    raise_exception(res)
      end
    end

    def gather_partial_content(api_req, res)
      list_head = JSON.parse(res.body)
      etag, list_tail =
        self.send(
          api_req.method,
          api_req.end_point,
          range: res["Next-Range"]
        )

      list_tail.unshift(*list_head)
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
        "Authorization" => Heroku::Properties.auth_token,
        "User-Agent"    => Heroku::Properties::USER_AGENT
      }.merge({}.tap do |header|
        header["If-None-Match"] = opts[:etag]  if opts[:etag]
        header["Range"]         = opts[:range] if opts[:range]
      end)
    end
  end
end
