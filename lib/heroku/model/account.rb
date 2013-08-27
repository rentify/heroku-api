require 'heroku/api/password'

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

  include Heroku::API::Password

  def initialize(params = {})
    super(*params.values_at(*members.map(&:to_s)))
  end

  def patchable
    Hash[[:email, :allow_tracking].map { |k| [k, send(k)] }]
  end

  def save
    owner.update_account(self)
  end

end
