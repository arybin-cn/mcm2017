require 'pry'

class Class
  #note: i(integer) r(rational) f(float) s(string)
  def simple_attr(*args)
    attr_accessor *args
    define_method :initialize do |args|
      self.class.instance_methods.grep(/=$/).tap do |ms|
        for i in 0..args.length-1
          send(ms[i],args[i])
        end
      end
    end
  end
end
