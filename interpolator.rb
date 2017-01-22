require './variables'

module MCM

  module Interpolator
  end

  include Variables

  module Interpolator
    module Car
    end
  end

  class Interpolator::Car::AccelerationSpeed
    def self.interpolate(car,time_has_passed_in_second)

    end
  end

  class Interpolator::Car::State
    def self.interpolate(car,time_has_passed_in_second)

    end
  end

  class Interpolator::Car::Speed
    def self.interpolate(car,time_has_passed_in_second)

    end
  end

end
