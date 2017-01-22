module Kernel
  def auto_require(str)
    for file in Dir[str].select{|file| file.end_with? '.rb'}.map{|file| './'+file}
      require file
    end
  end
end
