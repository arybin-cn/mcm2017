module MCM
  class Model::Intersection 
    include Utils
    attr_accessor :cars
    #Position in current route.
    attr_accessor :position
    attr_accessor :approaching_road,:leaving_road
    def initialize
      @cars=[]
    end


    def clear
      @cars=[]
    end

    def update(seconds_passed)
      if @cars and @cars.size > 0
        for car in @cars
          inc_mp = (car.end_intersection.position>=car.start_intersection.position)
          if inc_mp
            #available_lane=random_select(@leaving_road.inc_lanes)
            available_lane=@leaving_road.inc_lanes.find do |lane|
              lane.cars.size==0 or (lane.cars.last.position-lane.cars.last.length > car.length)
            end
          else
            #available_lane=random_select(@approaching_road.dec_lanes)
            available_lane=@approaching_road.dec_lanes.find do |lane|
              lane.cars.size==0 or (lane.cars.last.position-lane.cars.last.length > car.length)
            end
          end
          if available_lane
            @cars.delete(car)
            available_lane.cars<<car
            car.lane=available_lane
            car.position=car.length
          end
        end
      end
    end

  end
end
