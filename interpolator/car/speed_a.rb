#This file show examples about how to change inner Object with outer Interpolator
#To add more car Interpolators like this one(which takes effect when state of car is updated)
#You just need adding more Interpolator ruby code file like this one in current directory(./interpolator/car)
module MCM
  module Interpolator
    module Car
      class SpeedA
        def self.update(car)
          #Do something else to modify speed of the argument car
          #refine the speed of current car through the speed of previous car
          car.speed=(4*car.speed+car.previous_car.speed)/5
        end
      end
    end
  end
end
