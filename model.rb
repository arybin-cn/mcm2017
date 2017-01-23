require './variables'
require './utils/simple_accessor'
require './utils/colorize_string'
require './utils/bound_number'

module MCM
  module Model
  end

  include Variables
  #Module that generates stub "update" method for ditinguish normal model and (state)updatable model
  #In our methematical model, both roads and lanes as well as cars on lanes and intersections between roads are updatable.
  #The update interval is determined by the simulated o'clock(the event interval).
  module Model::Updatable
    attr_accessor :state
    def update(seconds_passed)
    end
  end

  class Model::BasicModel
  end

  class Model::UpdatableModel < Model::BasicModel
    include Model::Updatable
  end

  #A route contains many roads, so as intersections.
  class Model::Route < Model::UpdatableModel
    attr_accessor :id,:roads,:intersections
    def update(seconds_passed)
      for road in @roads
        road.update(seconds_passed)
      end
    end

    def cars
      cars=[].tap do |cars|
        @roads.each do |road|
          cars<<road.cars
        end
      end
      cars.flatten.uniq
    end
  end

  #Unit of length of road is mile.
  #desc_lanes are first the number of lanes and then initialized as the Lane objects. incr_lanes are similar.
  class Model::Road < Model::UpdatableModel
    simple_attr *%i{id start_milepost end_milepost traffic_count rte_type dec_lanes inc_lanes}
    attr_accessor :length,:start_intersection,:end_intersection
    def to_s
      '#'*@@screen_width_in_char+"\n"+
        inc_lanes.inject{|lane_a,lane_b| "#{lane_a}#{lane_b}"}+
        '-'*@@screen_width_in_char+"\n"+
        dec_lanes.inject{|lane_a,lane_b| "#{lane_a}#{lane_b}"}+
        '#'*@@screen_width_in_char
    end

    def cars
      cars=[].tap do |cars|
        [@inc_lanes,@dec_lanes].each do |lanes|
          lanes.each do |lane|
            cars<<lane.cars
          end
        end
      end
      cars.flatten.uniq
    end

    def update(seconds_passed)
      [@inc_lanes,@dec_lanes].each do |lanes|
        for lane in lanes
          lane.update(seconds_passed)
        end
      end
      @start_intersection.update(seconds_passed)
    end

  end

  class Model::Intersection < Model::UpdatableModel
    include Utils
    attr_accessor :cars
    #Position in current route.
    attr_accessor :position
    attr_accessor :approaching_road,:leaving_road

    def initialize
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
              lane.cars.size==0 or (lane.road.length-lane.cars.last.position > car.length)
            end
          end
          if available_lane
            @cars.delete(car)
            available_lane.cars<<car
            car.lane=available_lane
            car.position=inc_mp ? car.length : available_lane.road.length - car.length
          end
        end
      end
    end

  end

  #Lane belongs to road and has many cars on it.The length of a lane is the same with the length of the road it belongs to.
  #As the given conditions, the width of lane is standard, so we dont consider width of lane here.
  #Insteand, we assume that a lane is always suitable for one car in parallel.
  class Model::Lane < Model::UpdatableModel
    attr_accessor :road,:cars
    #true for INC-MP direction and false for DEC-MP direction.
    attr_accessor :inc_mp

    def initialize
      @cars=[]
    end


    %i{left right}.each do |relation|
      define_method "#{relation}_lane" do
        #lanes in the same road with same direction.
        related_lanes=self.road.send("#{self.inc_mp ? :inc : :dec}_lanes")
        index=related_lanes.find_index(self)+(relation==:left ? -1 : 1)
        index=related_lanes.length if index < 0
        related_lanes[index] rescue nil
      end
    end

    def neighbour_lanes
      [self.left_lane,self.right_lane]
    end


    def update(seconds_passed)
      if @cars and @cars.size>0
        for car in @cars
          car.update(seconds_passed)
        end
      end
    end

    def nearest_car_in_front_of(position)
      @cars.reverse_each.find{|car| car.position>position}
    end

    def nearest_car_behind_of(position)
      @cars.find{|car| car.position<position}
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
  #
  #
  #State:
  # 1.normal
  # 2.overtake
  class Model::Car < Model::UpdatableModel
    include Variables
    attr_accessor :start_intersection,:end_intersection,:speed,:length
    #The speed of acceleration
    #attr_accessor :acceleration_speed
    #The speed of car
    attr_accessor :speed
    #Relative position to the start point of current lane. 
    attr_accessor :position
    #Color was use in printing.
    attr_accessor :color
    #Current running lane.
    attr_accessor :lane
    def initialize(start_intersection,end_intersection,initial_speed,length)
      @speed=initial_speed
      @start_intersection=start_intersection
      @end_intersection=end_intersection
      @length=length
      @color=String.rand_color
    end

    #The car in front of current car in the same lane.
    def previous_car
      index = @lane.cars.find_index(self)
      return nil if index == 0
      return @lane.cars[index-1]
    end

    def distance_to_previous_car
      previous_car=self.previous_car
      (previous_car.position-previous_car.length-@position) rescue -1
    end

    #Stub Method for overwriting
    def reaction_time
    end

    #The car behind current car in the same lane.
    def next_car
      index = @lane.cars.find_index(self)
      return nil if index == @lane.cars.size-1
      return @lane.cars[index+1]
    end

    def distance_to_next_car
      (@position - @length - self.next_car.position) rescue -1
    end

    #Base on SDA-Safe-Headway model
    def safe_headway
      previous_car = self.previous_car
      @speed*self.reaction_time+(@speed**2 - previous_car.speed**2)/(2*5.88)
    end

    def head_way
      self.safe_headway * self.headway_scale
    end


    #Stub Method for overwriting
    def headway_scale
    end

    def update(seconds_passed)
      #speed change
      new_speed=@speed #+ @acceleration_speed*seconds_passed
      new_speed=new_speed.bound(0,@@car_max_speed)
      #position change
      new_position=@position+@speed*seconds_passed*(@lane.inc_mp ? 1 : -1)
      new_position=new_position.bound(0,@lane.road.length)

      previous_car=self.previous_car
      if previous_car 
        if @lane.inc_mp
          new_position = new_position.bound(0,previous_car.position-previous_car.length-self.head_way) do
            @state=:overtake
          end
        else
          new_position = new_position.bound(previous_car.position+@length+self.head_way,@lane.road.length) do
            @state=:overtake
          end
        end
      end
      @position = new_position
      @speed = new_speed
      @lane.cars.delete(self) if @position >= @lane.road.length or @position <= 0

      #if  @position >= @lane.road.length or @position <= 0
      #  return @lane.cars.delete(self)
      #end
      ##speed change
      #new_speed=@speed #+ @acceleration_speed*seconds_passed
      #new_speed=new_speed.bound(0,@@car_max_speed)
      ##position change
      #new_position=@position+@speed*seconds_passed*(@lane.inc_mp ? 1 : -1)
      #new_position=new_position.bound(0,@lane.road.length)
      #case @state
      #when :normal
      #  previous_car = self.previous_car
      # if previous_car 
      #   if @lane.inc_mp
      #     new_position = new_position.bound(0,previous_car.position-previous_car.length-self.head_way) do
      #       @state=:overtake
      #     end
      #   else
      #     new_position = new_position.bound(previous_car.position+@length+self.head_way,@lane.road.length) do
      #       @state=:overtake
      #     end
      #   end
      # end
      #when :overtake
      #  available_lane=@lane.neighbour_lanes.find do |lane|
      #  end
      #end
    end

    class Model::SelfdrivingCar < Model::Car
      def headway_scale
        @@sdcar_headway_scale
      end

      def reaction_time
        @@sdcar_reaction_time
      end

    end

    class Model::CommonCar < Model::Car
      def headway_scale
        @@cmcar_headway_scale
      end

      def reaction_time
        @@cmcar_reaction_time
      end

    end

  end
end
