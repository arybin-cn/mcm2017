module MCM
  module Simulator

    #Simulate situations for specific route.
    class VirtualMachine
      attr_accessor :event_interval,:print_interval
      attr_accessor :monitor,:route
      attr_accessor :total_interval_count
      attr_accessor :event_drivers
      #time_scale represents how many seconds does real world pass when the simulator passes one event_interval
      #the unit of event_interval and print_interval is second
      def initialize(total_interval_count,event_interval,print_interval,route,monitor,event_drivers,time_scale=1)
        @total_interval_count=total_interval_count
        @event_interval=event_interval
        @print_interval=print_interval
        @route=route
        @monitor=monitor
        @event_drivers=event_drivers
        @time_scale=time_scale
      end


      def start
        #Event thread.
        event_thread = Thread.new do
          @total_interval_count.times do
            @route.update(@time_scale)
            for event_driver in @event_drivers
              event_driver.update(@time_scale)
            end
            sleep(@event_interval)
          end
        end

        #Print thread.
        print_thread = Thread.new do
          loop do
            @monitor and @monitor.print
            sleep(@print_interval)
          end
        end

        event_thread.join
        print_thread.join


      end

    end


  end
end
