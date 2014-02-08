# -*- coding: utf-8 -*-
require "Yamate/version"
require "faraday"
require "json"
#require "faraday_middleware"


module Yamate
  # Your code goes here...
      
  class APIClient
    @@entry_point = "https://api.odpt.org"
    def initialize(consumer_key)
      @consumer_key = consumer_key
      @conn = Faraday::Connection.new(:url => @@entry_point) do |builder| 
        builder.use Faraday::Request::UrlEncoded
        builder.use Faraday::Response::Logger
        builder.use Faraday::Adapter::NetHttp 
        #builder.response :json, :content_type => /\bjson/
      end
    end

    def get_trains_data()
      response = @conn.get '/api/v2/datapoints', {"rdf:type" => "odpt:Train", "acl:accessTarget" => "JR-East:YamanoteLine", "acl:consumerKey" => @consumer_key}
      return JSON.parse(response.body)
    end
  end

  class TrainState
    attr_reader :from_station_name, :to_station_name, :progress, :line_name
    
    def initialize(from_station_name, to_station_name, progress, line_name)
      @from_station_name = from_station_name
      @to_station_name   = to_station_name
      @progress          = progress
      @line_name         = line_name

    end

    def estimate_next_step(theta, station_rad, step)
      if @to_station_name == nil then
        interval = 0.0
      else
        interval = station_rad[@to_station_name].to_f - station_rad[@from_station_name].to_f
      end

      if interval.abs > 5.0 then
        interval = 0.0
      end
      return theta + interval * 0.012
    end
  end

  class Train

    @@line_name = {
      "外回" => "outside_line",
      "内回" => "inside_line"
    }

    @@station_rad = {
      "秋葉原" => 0.05,
      "神田"   => 0.3,
      "東京"   => 0.5,
      "有楽町" => 0.7,
      "新橋"   => 0.9,
      "浜松町" => 1.1,
      "田町"   => 1.32,
      "品川"   => 1.58,
      "大崎"   => 1.86,
      "五反田" => 2.07,
      "目黒"   => 2.24,
      "恵比寿" => 2.38,
      "渋谷"   => 2.55,
      "原宿"   => 2.75,
      "代々木" => 3.0,
      "新宿"   => 3.26,
      "新大久保" => 3.5,
      "高田馬場" => 3.7,
      "目白" => 3.8,
      "池袋" => 4.02,
      "大塚" => 4.15,
      "巣鴨" => 4.36,
      "駒込" => 4.6,
      "田端" => 4.87,
      "西日暮里" => 5.13,
      "日暮里" => 5.33,
      "鶯谷" => 5.63,
      "上野" => 5.83,
      "御徒町" => 6.05
    }

    @@radius = 1
    
    def initialize(id, from_station_name, to_station_name, progress, line_name, is_operation, train_number, delay)
      @id    = id
      @x     = 0
      @y     = 0
      @line_name = @@line_name[line_name]
      @step  = 0
      @is_operation = is_operation
      @train_number = train_number
      @delay  = delay

      @pre_state = TrainState.new(from_station_name, to_station_name, progress, line_name)

      if to_station_name == nil then
        dist = 0.0
      else
        dist = (@@station_rad[to_station_name].to_f - @@station_rad[from_station_name].to_f) * progress
      end
      
      @theta = @@station_rad[from_station_name] + dist
    end

    def self.get_station_names()
      return @@station_rad.keys
    end

    def estimate()
      @theta = @pre_state.estimate_next_step(@theta, @@station_rad, @step)
      @step += 1
    end

    def which_quadrant()
      remain = @theta % (2*Math::PI)
      if remain >= (7*Math::PI)/4 || remain < (Math::PI)/4 then
        return 0
      elsif (Math::PI)/4 <= remain && remain < (3*Math::PI)/4 then
        return 1 
      elsif (3*Math::PI)/4 <= remain && remain < (5*Math::PI)/4 then
        return 2
      else
        return 3
      end
    end

    def update()
      if self.which_quadrant == 0 then
        @x = @@radius
        @y = @@radius * Math.tan(@theta)
      elsif self.which_quadrant == 1 then
        @x = @@radius / Math.tan(@theta)
        @y = @@radius
      elsif self.which_quadrant == 2 then
        @x = -@@radius
        @y = -@@radius * Math.tan(@theta)
      else
        @x = -@@radius / Math.tan(@theta)
        @y = -@@radius
      end
    end
        
    def move()
      @theta += 0.04
      self.update()
    end

    def get_position()
      return {:id => @id, :x => @x, :y => @y, :line_name => @line_name, :is_operation => @is_operation, :train_number => @train_number, :delay => @delay }
    end
  end
  
end
