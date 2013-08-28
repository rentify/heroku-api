require 'heroku/conn'

module Heroku::API::RateLimits
  @@etag = nil

  def rate_limits
    @@etag, res = Heroku::Conn::Get("/account/rate-limits", etag: @@etag)
    res["remaining"].to_i
  end
end
