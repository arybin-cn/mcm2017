module MCM
  module Variables
    #Method for convenient access for class variables.
    class << self
      def [](index)
        class_variable_get("@@#{index}")
      end
    end


    #Set global controllable variables as class variable below.
    @@screen_width_in_char = 80
    #1 mile = 1609 meters
    @@scale_of_road_length = 1609
    #max speed of car(m/s), 60 miles/h = 26.82 m/s
    @@car_max_speed = 26.82
    #random process of speed change
    @@car_amplitude_of_speed_change = 0.1
    #disturb scale
    @@sdcar_disturb_scale = 0.2
    #abbr of technology level which measures the degree of development of self-driving cars.
    @@tech_lv=0.8

    #Note prefix cmcar_ means common cars and sdcar_ means self-driving cars
    #1.reaction time
    @@cmcar_reaction_time = 1 #Unit: second
    @@sdcar_reaction_time = @@cmcar_reaction_time * (0.3/@@tech_lv)
    #2.safe headway scale
    @@cmcar_headway_scale = 1.8
    @@sdcar_headway_scale = 1.0/@@tech_lv

    #3.probability scale of accelerating





  end
end
