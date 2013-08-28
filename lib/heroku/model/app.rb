require 'heroku/model'

class Heroku::Model::App < Struct.new(
  :parent,
  :id,
  :name,
  :owner,
  :region,
  :git_url,
  :web_url,
  :repo_size,
  :slug_size,
  :buildpack_provided_description,
  :stack,
  :maintenance,
  :archived_at,
  :created_at,
  :released_at,
  :updated_at
)

  include Heroku::Model::HashHelpers

  def inspect
    "#<#{self.class.name} id=#{id}, name=#{name}>"
  end

  def initialize(params = {})
    super(*struct_init_from_hash(params))
  end

  def patchable
    sub_struct_as_hash(:maintenance, :name)
  end

  def identifying
    Hash[[:maintenance]]
  end
end
