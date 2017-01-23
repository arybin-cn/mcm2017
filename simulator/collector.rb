require './variables'

module MCM
  class Simulator::Collector
    include Variables
    attr_accessor :average_car_speed
    def initialize
      @average_car_speed=@@car_max_speed
    end
    def update(event_machine)
      cars_on_route=event_machine.route.cars
      if cars_on_route.size > 0
        average_speed = cars_on_route.map(&:speed).inject{|a,b| a+b}*1.0/cars_on_route.size
        @average_car_speed = (@average_car_speed+average_speed)/2
      end
    end
    def finish(event_machine)
      puts "#{event_machine.drivers.first.percentage_of_sdcars}  #{@average_car_speed}"
    end
  end
end
