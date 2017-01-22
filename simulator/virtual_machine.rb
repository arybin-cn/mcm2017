module MCM
  module Simulator

    #Simulate situations for specific route.
    class VirtualMachine
      attr_accessor :event_interval,:print_interval
      attr_accessor :monitor,:route
      attr_accessor :total_interval_count
      #time_scale represents how many seconds does real world pass when the simulator passes one event_interval
      #the unit of event_interval and print_interval is second
      def initialize(total_interval_count,event_interval,print_interval,route,monitor,time_scale=10)
        @total_interval_count=total_interval_count
        @event_interval=event_interval
        @print_interval=print_interval
        @route=route
        @monitor=monitor
        @time_scale=time_scale
      end


      def start
        #Event thread.
        event_thread = Thread.new do
          @total_interval_count.times do
            @route.update(@time_scale)
            sleep(@event_interval)
          end
        end

        #Print thread.
        print_thread = Thread.new do
          loop do
            @monitor.print
            sleep(@print_interval)
          end
        end

        event_thread.join
        print_thread.join


      end

    end


  end
end
