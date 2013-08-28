module Heroku::Model::HashHelpers
  def struct_init_from_hash(hash)
    hash.values_at(*members.map(&:to_s))
  end

  def sub_struct_as_hash(*params)
    Hash[params.map { |k| [k, send[k]] }]
  end
end
