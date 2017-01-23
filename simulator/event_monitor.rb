
module MCM
  module Simulator

    class Monitor
      def update
      end
    end

    class RoadMonitor < Monitor
      attr_accessor :roads
      def initialize(roads)
        @roads=roads
      end

      def update
        #Clear the screen.
        system('clear')
        for road in @roads
          puts '',road
        end
      end

    end
  end
end
