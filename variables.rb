module MCM
  module Variables
    #Method for convenient access for class variables.
    class << self
      def [](index)
        class_variable_get("@@#{index}")
      end
    end


    #Set global controllable variables as class variable below.
    
    @@screen_width_in_char = 120

    #1 mile = 1609 meters
    @@scale_of_road_length = 1609






  end
end
