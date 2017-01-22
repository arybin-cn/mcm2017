
module MCM
  module Simulator

    class Monitor
      def print
      end
    end

    class RoadMonitor < Monitor
      attr_accessor :roads
      def initialize(roads)
        @roads=roads
      end

      def print
        #Clear the screen.
        system('clear')
        for road in @roads
          puts '',road
        end
      end

    end
  end
end
