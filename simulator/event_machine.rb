module MCM
  module Simulator

    #Simulate situations for specific route.
    class EventMachine
      attr_accessor :event_interval,:monitor_interval,:route
      attr_accessor :total_interval_count
      attr_accessor :event_drivers,:event_monitors
      attr_accessor :datapicker
      #time_scale represents how many seconds does real world pass when the simulator passes one event_interval
      #the unit of event_interval and monitor_interval is second
      def initialize(total_interval_count,event_interval,monitor_interval,route,event_monitors,event_drivers,datapicker,time_scale=1)
        @total_interval_count=total_interval_count
        @event_interval=event_interval
        @monitor_interval=monitor_interval
        @route=route
        @event_monitors=event_monitors
        @event_drivers=event_drivers
        @datapicker=datapicker
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
            @datapicker.update(self)
            sleep(@event_interval)
          end
          @datapicker.finish
        end

        #Monitor thread.
        monitor_thread = Thread.new do
          loop do
            if @event_monitors
              for event_monitor in @event_monitors
                event_monitor.update
              end
            end
            sleep(@monitor_interval)
          end
        end

        event_thread.join
        monitor_thread.join

      end
    end

  end
end
