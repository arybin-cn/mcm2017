require './utils/object_selector'

module MCM
  module Simulator
    class EventDriver
      #Stub Method for overwriting
      def update(seconds_passed)
      end
    end

    class CarGenerator < EventDriver
      include ::MCM::Model
      include ::MCM::Variables
      include ::MCM::Utils
      attr_accessor :target_route
      attr_accessor :total_count_of_cars #Unit: car
      attr_accessor :total_time #Unit: second
      attr_accessor :percentage_of_sdcars
      def initialize(percentage_of_sdcars,target_route,total_count_of_cars,total_time)
        @percentage_of_sdcars=percentage_of_sdcars
        @target_route=target_route
        @total_count_of_cars=total_count_of_cars
        @total_time=total_time
      end

      def update(seconds_passed)
        #count of cars generated in current update
        count=(@total_count_of_cars*seconds_passed*1.0/total_time).to_i
        #distribute these generated cars to different roads in the route
        weights=@target_route.roads.map(&:traffic_count)
        count.times do
          target_road=weighted_select(@target_route.roads,weights)
          intersections=[target_road.start_intersection,target_road.end_intersection]
          from=weighted_select(intersections,[target_road.inc_lanes.size,target_road.dec_lanes.size])
          to=(intersections-[from]).first
          #(start_intersection,end_intersection,initial_speed,length)
          klass_of_car=weighted_select([CommonCar,SelfdrivingCar],[1-@percentage_of_sdcars,@percentage_of_sdcars])
          car = klass_of_car.new(from,to,23+rand(@@car_max_speed-24),3.8+rand(1.0))
          from.cars<<car
        end

      end
    end
  end
end
