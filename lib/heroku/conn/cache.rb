require 'json'

class Heroku::Conn::Cache
  CachePair = Struct.new(:response, :etag)

  def initialize()
    @response_cache = {}
    @etag_pointers  = {}
  end

  def put(r_type, new_etag, json)
    pair        = pair(r_type)
    key         = key(json)
    old_etag, _ = pair.response[key]
    record      = [new_etag, json]

    pair.etag.delete(old_etag)
    pair.response[key]  = record
    pair.etag[new_etag] = record
    record
  end

  def fetch(r_type, etag)
    pair(r_type).etag[etag]
  end

private

  def pair(r_type)
    CachePair[
      @response_cache[r_type] ||= {},
      @etag_pointers[r_type]  ||= {}
    ]
  end

  def key(json_response)
    case json_response
    when Array then "list"
    when Hash  then json_response['id']
    else            nil
    end
  end
end
