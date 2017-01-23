require './variables'
require './utils/simple_accessor'
require './utils/colorize_string'
require './utils/bound_number'

module MCM
  class Model::Car
    include Math
    include Utils
    include Variables
    attr_accessor :start_intersection,:end_intersection,:speed,:length
    #The speed of car
    attr_accessor :speed
    #Relative position to the start point of current lane. 
    attr_accessor :position
    #Color was use in printing.
    attr_accessor :color
    #Character use to identify
    attr_accessor :character
    #Current running lane.
    attr_accessor :lane

    def initialize(start_intersection,end_intersection,initial_speed,length)
      @state=:normal
      @speed=initial_speed
      @start_intersection=start_intersection
      @end_intersection=end_intersection
      @length=length
      @color=String.rand_color
      @character=random_select(('a'..'z').to_a)
    end

    #The car in front of current car in the same lane.
    def previous_car
      index = @lane.cars.find_index(self)
      return nil if index == 0
      return @lane.cars[index-1]
    end

    #return -1 if the car has no previous car.
    def distance_to_previous_car
      (self.previous_car.position-self.previous_car.length-@position) rescue -1
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
      @speed*self.reaction_time+(@speed**2 - (previous_car.speed**2 rescue 0))/(2*5.88)
    rescue
      @length
    end

    def headway
      self.safe_headway * self.headway_scale
    end


    #Stub Method for overwriting
    def headway_scale
    end

    def update(seconds_passed)
      #speed change
      #probability of slowing speed
      a=E**(0.01*(60-@speed*2.25))-1
      #probability of accelerating speed
      b=E**(0.01*(@speed*2.25-20))-1
      new_speed=@speed*weighted_select([1+@@car_amplitude_of_speed_change,1-@@car_amplitude_of_speed_change,1],[a,b,1-a-b])
      new_speed=new_speed.bound(0,@@car_max_speed)
      #position change
      new_position=@position+@speed*seconds_passed

      case @state
      when :normal
        previous_car=self.previous_car
        if previous_car
          new_position = new_position.bound(0,previous_car.position-previous_car.length - self.headway) do
            @state = :overtake
            new_speed=previous_car.speed
          end
        end
      when :overtake
        available_lane = @lane.neighbour_lanes.find do |lane|
          headway = self.headway
          lane.distance_to_previous_car(new_position) > headway and 
            lane.distance_to_next_car(new_position) > headway
        end
        if available_lane
          @lane.cars.delete(self)
          @lane=available_lane
          @lane.cars.insert((@lane.cars.index(@lane.previous_car(new_position))+1 rescue 0),self)
          @state=:normal
        end
      end
      @position = new_position
      @speed = new_speed
      if  @position >= @lane.road.length or @position <= 0
        @lane.cars.delete(self)
      end
    end
  end

  class Model::CommonCar < Model::Car
    def headway_scale
      @@cmcar_headway_scale
    end

    def update(seconds_passed)
      super(seconds_passed)
    end

    def reaction_time
      @@cmcar_reaction_time
    end

  end


  class Model::SelfdrivingCar < Model::Car
    def headway_scale
      @@sdcar_headway_scale
    end

    def update(seconds_passed)
      super(seconds_passed)
      @speed=(@speed+8*@@car_max_speed)/9
      if self.previous_car.is_a? Model::SelfdrivingCar 
        #disturbed
        @speed=@speed*(@@sdcar_disturb_scale*@@tech_lv)
      end
    rescue
    end

    def reaction_time
      @@sdcar_reaction_time
    end

  end

end
