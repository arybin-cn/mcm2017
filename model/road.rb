require './variables'
require './utils/simple_accessor'

module MCM
  #Unit of length of road is mile.
  #desc_lanes are first the number of lanes and then initialized as the Lane objects. incr_lanes are similar.
  include Variables
  class Model::Road 
    simple_attr *%i{id start_milepost end_milepost traffic_count rte_type dec_lanes inc_lanes}
    attr_accessor :length,:start_intersection,:end_intersection

    def clear
      @start_intersection.clear
      @end_intersection.clear
      [@inc_lanes,@dec_lanes].each do |lanes|
        lanes.each do |lane|
          lane.clear
        end
      end
    end

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
    end

  end
end
