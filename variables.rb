module MCM
  module Variables
    #Method for convenient access for class variables.
    class << self
      def [](index)
        class_variable_get("@@#{index}")
      end
    end


    #Set global controllable variables as class variable below.
    @@screen_width_in_char = 128
    #1 mile = 1609 meters
    @@scale_of_road_length = 1609
    #max speed of car(m/s), 60 miles/h = 26.82 m/s
    @@car_max_speed = 26.82

    #abbr of technology leval which measures the degree of development of self-driving cars.
    @@tech_lv=0.7

    #Note prefix cmcar_ means common cars and sdcar_ means self-driving cars
    #1.reaction time
    @@cmcar_reaction_time = 1 #Unit: second
    @@sdcar_reaction_time = @@cmcar_reaction_time * (0.3/@@tech_lv)
    #2.safe headway scale
    @@cmcar_headway_scale = 1.8
    @@sdcar_headway_scale = 1.0/@@tech_lv

    #3.probability of slowing
    @@cmcar_slow_p = 0





  end
end
