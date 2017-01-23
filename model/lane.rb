#Lane belongs to road and has many cars on it.The length of a lane is the same with the length of the road it belongs to.
#As the given conditions, the width of lane is standard, so we dont consider width of lane here.
#Insteand, we assume that a lane is always suitable for one car in parallel.
module MCM
  class Model::Lane 
    include Utils
    attr_accessor :road,:cars
    #true for INC-MP direction and false for DEC-MP direction.
    attr_accessor :inc_mp

    def clear
      @cars=[]
    end

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
      [self.left_lane,self.right_lane].compact
    end

    def update(seconds_passed)
      if @cars and @cars.size>0
        for car in @cars
          car.update(seconds_passed)
        end
      end
    end

    def previous_car(position)
      @cars.reverse_each.find{|car| car.position>position}
    end
    def distance_to_previous_car(position)
      previous_car = self.previous_car(position)
      (previous_car.position - previous_car.length - position) rescue -1
    end

    def next_car(position)
      @cars.each.find{|car| car.position<position}
    end
    def distance_to_next_car(position)
      (position-self.next_car(position).position) rescue -1
    end

    def to_s
      direction=(@inc_mp ? '>' : '<')
      raw=direction*@@screen_width_in_char+"\n"
      length=@road.length
      index_method=@inc_mp ? :rindex : :index
      self.cars.each do |car|
        index=(@@screen_width_in_char*car.position/length).to_i
        raw[@inc_mp ? index : @@screen_width_in_char - index - 1]='?'
      end
      self.cars.each do |car|
        raw[raw.send(index_method,'?')]=(car.character).send("on_#{car.color}")
      end
      raw
    rescue
      raw
    end

  end
end
