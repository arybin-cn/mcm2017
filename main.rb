#!/usr/bin/env ruby

require 'pry'
require 'csv'

require './structure'

require './model/route'
require './model/road'
require './model/lane'
require './model/car'
require './model/intersection'

require './utils/object_selector'

require './simulator/collector'
require './simulator/machine'
require './simulator/driver'
require './simulator/monitor'

include MCM
include MCM::Model
include MCM::Utils
include MCM::Simulator

#Start parsing data to build data structure.
#############################################

#Raw string data
@roads = [].tap do |roads|
  CSV.foreach('data.csv') do |road_data|
    roads<<Road.new(road_data)
  end
end

#Typed data and generate length attribute.
@roads.map! do |road|
  %i{id traffic_count dec_lanes inc_lanes}.each do |attr|
    road.send("#{attr}=",road.send(attr).to_i)
  end
  %i{start_milepost end_milepost}.each do |attr|
    road.send("#{attr}=",road.send(attr).to_f)
  end
  road.length = (road.end_milepost - road.start_milepost)*Variables[:scale_of_road_length]
  road
end

#Generate intersections and route from roads.
@routes = [].tap do |routes|
  @roads.map(&:id).uniq.each do |route_id|
    routes<<Route.new.tap do |route|
      route.id=route_id
      route.roads=@roads.select{|road| road.id==route_id}
      route.intersections=[].tap do |intersections|
        route.roads.each do |road|
          intersections<<Intersection.new.tap do |intersection|
            intersection.position=road.start_milepost
          end
        end
        intersections<<Intersection.new.tap do |intersection|
          intersection.position=route.roads.last.end_milepost
        end
      end
    end
  end
end


#Bind intersections to road(each road has a start intersection and an end intersection)
@routes.each do |route|
  (0..route.roads.length-1).each do |i|
    route.roads[i].start_intersection=route.intersections[i]
    route.roads[i].end_intersection=route.intersections[i+1]
  end
end

#Bind roads to intersection(each intersection has a entering road and a leaving road).
@routes.each do |route|
  (0..route.intersections.length-1).each do |i|
    route.intersections[i].approaching_road=route.roads[i-1 > -1 ? i-1 : route.roads.length] rescue nil
    route.intersections[i].leaving_road=route.roads[i]
  end
end

#Generate lanes of roads in each direction.
@routes.each do |route|
  route.roads.each do |road|
    %i{inc dec}.each do |direction|
      count=road.send("#{direction}_lanes")
      lanes=[].tap do |lanes|
        count.times do
          lanes<<Lane.new.tap do |lane|
            lane.road=road
            lane.inc_mp=(direction==:inc)
          end
        end
      end
      road.send "#{direction}_lanes=",lanes
    end
  end
end

#Succeed to parse given data.
#############################################

#Now check our model
route=@routes.last
total_count_of_cars=4000
total_interval_count=50
event_interval=1
print_interval=1
percentage_of_sdcars=0.4

driver=CarGenerator.new(percentage_of_sdcars,route,total_count_of_cars,total_interval_count)
monitor=RoadMonitor.new(route.roads[0..3])
collector=Collector.new
Machine.new(total_interval_count,event_interval,print_interval,route,[monitor],[driver],collector).start
