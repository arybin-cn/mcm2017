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
        #system('clear')
        output = @roads.inject{|road_a,road_b| "#{road_a}\n\n#{road_b}"}
        $stdout.print output+"\r"
      end

    end
  end
end
