module MCM
  module Utils

    def random_select(objects)
      return nil unless objects
      objects[rand objects.length]
    end

    def weighted_select(objs,weights)
      return nil if (objs.size != weights.size rescue true)
      total_weight = weights.inject{|a,b| a+b}
      random = rand(total_weight)
      accumulated_weight = 0
      for i in 0..weights.size-1
        accumulated_weight=accumulated_weight+weights[i]
        break if accumulated_weight>random
      end
      objs[i]
    end 
  end
end
