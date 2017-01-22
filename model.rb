require './variables'
require './utils/simple_accessor'
require './utils/colorize_string'

module MCM
  module Model

    include ::MCM::Variables
    #Module that generates stub "update" method for ditinguish normal model and (state)updatable model
    #In our methematical model, both roads and lanes as well as cars on lanes and intersections between roads are updatable.
    #The update interval is determined by the simulated o'clock.
    module Updatable
      attr_accessor :state
      def update(time_has_passed_in_second)
      end
    end

    class BasicModel
      include Updatable
    end

    class UpdatableModel
      include Updatable
    end

    #A route contains many roads, so as intersections.
    class Route < UpdatableModel
      attr_accessor :id,:roads,:intersections
      def update(time_has_passed_in_second)
        for road in @roads
          road.update(time_has_passed_in_second)
        end
      end
    end

    #Unit of length of road is mile.
    #desc_lanes are first the number of lanes and then initialized as the Lane objects. incr_lanes are similar.
    class Road < UpdatableModel
      simple_attr *%i{id start_milepost end_milepost traffic_count rte_type dec_lanes inc_lanes}
      attr_accessor :length,:start_intersection,:end_intersection
      def to_s
        '#'*@@screen_width_in_char+"\n"+
          inc_lanes.inject{|lane_a,lane_b| "#{lane_a}#{lane_b}"}+
          '-'*@@screen_width_in_char+"\n"+
          dec_lanes.inject{|lane_a,lane_b| "#{lane_a}#{lane_b}"}+
          '#'*@@screen_width_in_char
      end

      def update(time_has_passed_in_second)
        [@inc_lanes,@dec_lanes].each do |lanes|
          for lane in lanes
            lane.update(time_has_passed_in_second)
          end
        end
      end

    end

    class Intersection < UpdatableModel
      attr_accessor :cars
      #Position in current route.
      attr_accessor :position
      attr_accessor :approaching_road,:leaving_road
    end

    #Lane belongs to road and has many cars on it.The length of a lane is the same with the length of the road it belongs to.
    #As the given conditions, the width of lane is standard, so we dont consider width of lane here.
    #Insteand, we assume that a lane is always suitable for one car on parallel.
    class Lane < UpdatableModel
      attr_accessor :road,:cars
      #true for INC-MP direction and false for DEC-MP direction.
      attr_accessor :inc_mp

      %i{left right}.each do |relation|
        define_method "#{relation}_lane" do
          #lanes in the same road with same direction.
          related_lanes=self.road.send("#{self.inc_mp ? :inc : :dec}_lanes")
          index=related_lanes.find_index(self)+(relation==:left ? -1 : 1)
          index=related_lanes.length if index < 0
          related_lanes[index] rescue nil
        end
      end


      def update(time_has_passed_in_second)
        for car in @cars
          car.update(time_has_passed_in_second)
        end
      rescue
      end

      def to_s
        direction=(self.inc_mp ? '>' : '<')
        raw=direction*@@screen_width_in_char+"\n"
        length=@road.length
        for car in self.cars
          raw[(@@screen_width_in_char*car.position/length).to_i]='?'
        end
        for car in self.cars
          raw[raw.index('?')]=direction.send("on_#{car.color}")
        end
        raw
      rescue
        raw
      end

    end

    #In our assumption:
    #1.One car belongs to one lane. The position of the car in the lane is determined by the attribute "position"
    #2.One car appears at a start intersection and heads for the end intersection.
    #3.One car always tries to overtake another car in the same lane.
    class Car < UpdatableModel
      attr_accessor :start_intersection,:end_intersection,:speed,:length
      #The unit of speed is meters per second.
      attr_accessor :speed
      #Relative position to the start point of current lane. 
      attr_accessor :position
      #Color was use in printing.
      attr_accessor :color
      #Current running lane.
      attr_accessor :lane
      def initialize(start_intersection,end_intersection,initial_speed)
        @speed=initial_speed
        @start_intersection=start_intersection
        @end_intersection=end_intersection
        @color=String.rand_color
      end

      def update(time_has_passed_in_second)
        @position = @position + @speed*time_has_passed_in_second*(@lane.inc_mp ? 1 : -1)
        @lane.cars.delete(self) if @position > @lane.road.length or @position < 0
      end 

    end

    class SelfdrivingCar < Car
    end

    class CommonCar < Car
    end

  end
end
