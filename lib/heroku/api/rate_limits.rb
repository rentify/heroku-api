require 'json'
require 'heroku/conn'

module Heroku::API::RateLimits
  @@etag = nil

  def rate_limits
    res = Heroku::Conn::Get("/account/rate-limits", etag: @@etag)
    @@etag = res["ETag"]
    JSON.parse(res.body)["remaining"].to_i
  end
end
