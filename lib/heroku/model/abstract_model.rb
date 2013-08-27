require 'ostruct'

class Heroku::Model::AbstractModel < OpenStruct

  def method_missing(name,*args)
    if /(.*)\?$/ =~ name
      self.send($1, *args)
    else
      super
    end
  end

end
