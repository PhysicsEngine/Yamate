# -*- coding: utf-8 -*-
require 'faye/websocket'
require 'json'
require 'Yamate'
require 'yaml'

module Yamate

  class Train
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
      "池袋" => 3.99,
      "大塚" => 4.125,
      "巣鴨" => 4.36,
      "駒込" => 4.6,
      "田端" => 4.87,
      "西日暮里" => 5.1,
      "日暮里" => 5.3,
      "鶯谷" => 5.63,
      "上野" => 5.83,
      "御徒町" => 6.05
    }
    
    @@radius = 1
    
    def initialize(id, station_name, progress)
      @id    = id
      @x     = 0
      @y     = 0
      @theta = @@station_rad[station_name] + progress*0.1
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
      return {:id => @id, :x => @x, :y => @y }
    end
  end
  
  class Backend
    KEEPALIVE_TIME = 15
    
    def initialize(app)
      @app = app
      @clients = []
      yamate_config = YAML.load_file('./conf/config.yml')

      ## TODO: Random initialization is not accurate for train position
      ##       it should be got API data
      @api_client = Yamate::APIClient.new(yamate_config["consumer_key"])
      self.update_train_data
    end

    def get_train_num()
      ret = @api_client.get_trains_data
      return ret.length
    end

    def get_trains()
      return @api_client.get_trains_data
    end

    def update_train_data()
      @trains = []
      train_data = self.get_trains
      train_data.each do |train|
        progress          = train["odpt:progress"]
        train_id          = train["@id"]
        from_station_name = train["odpt:fromStationName"]
        @trains.push(Train.new(train_id, from_station_name, progress))
      end
      @trains.each do |train|
        train.update
      end
    end
    
    def routine()
      self.update_train_data

      data = {}
      data[:trains] = []
      @trains.each do |train|
        data[:trains].push(train.get_position)
      end
      sleep 2
      @clients.each do |client|
        client.send(data.to_json)
      end
      self.routine
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, ping: KEEPALIVE_TIME)
        
        ws.on :open do |event|
          p [:open, ws.object_id]
          @clients << ws
          ws.send({ you: ws.object_id }.to_json)
          @clients.each do |client|
            client.send({ count: @clients.size }.to_json)
          end
        end

        ws.on :message do |event|
          p [:message, event.data]
          @clients.each { |client| client.send event.data }
        end

        ws.on :close do |event|
          p [:close, ws.object_id, event.code]
          @clients.delete(ws)
          @clients.each do |client|
            client.send({ count: @clients.size }.to_json)
          end
          ws = nil
        end
        ws.rack_response
        self.routine
      else
        @app.call(env)
      end
    end
  end
end
