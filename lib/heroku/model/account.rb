require 'heroku/api'
require 'heroku/model'

class Heroku::Model::Account < Struct.new(
  :owner,
  :id,
  :email,
  :verified,
  :allow_tracking,
  :beta,
  :last_login,
  :updated_at,
  :created_at
)

  include Heroku::Model::HashHelpers
  include Heroku::API::Password
  include Heroku::API::RateLimits

  def initialize(params = {})
    super(*struct_init_from_hash(params))
  end

  def patchable
    sub_struct_as_hash(:email, :allow_tracking)
  end

  def save
    owner.update_account(self)
  end

end
