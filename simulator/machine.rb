module MCM
  module Simulator

    #Simulate situations for specific route.
    class Machine
      attr_accessor :event_interval,:monitor_interval,:route
      attr_accessor :total_interval_count
      attr_accessor :drivers,:monitors
      attr_accessor :datapicker
      #time_scale represents how many seconds does real world pass when the simulator passes one event_interval
      #the unit of event_interval and monitor_interval is second
      def initialize(total_interval_count,event_interval,monitor_interval,route,monitors,drivers,datapicker,time_scale=1)
        @total_interval_count=total_interval_count
        @event_interval=event_interval
        @monitor_interval=monitor_interval
        @route=route
        @monitors=monitors
        @drivers=drivers
        @datapicker=datapicker
        @time_scale=time_scale
      end


      def start
        #Monitor thread.
        monitor_thread = Thread.new do
          loop do
            if @monitors
              for monitor in @monitors
                monitor.update
              end
            end
            sleep(@monitor_interval)
          end
        end
        
        #Event thread.
        event_thread = Thread.new do
          @total_interval_count.times do
            @route.update(@time_scale)
            for driver in @drivers
              driver.update(@time_scale)
            end
            @datapicker.update(self)
            sleep(@event_interval)
          end
          Thread.kill monitor_thread
          @datapicker.finish(self)
        end


        event_thread.join
        monitor_thread.join

      end
    end

  end
end
