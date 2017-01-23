module MCM
  class Model::Route 
    attr_accessor :id,:roads,:intersections
    def clear
      @roads.each do |road|
        road.clear
      end
    end
    def update(seconds_passed)
      for road in @roads
        road.update(seconds_passed)
      end
      for intersection in @intersections
        intersection.update(seconds_passed)
      end
    end

    def cars
      cars=[].tap do |cars|
        @roads.each do |road|
          cars<<road.cars
        end
        @intersections.each do |intersection|
          cars<<intersection.cars
        end
      end
      cars.flatten.uniq
    end
  end
end
