# -*- coding: utf-8 -*-
require 'faye/websocket'
require 'json'
require 'Yamate'
require 'yaml'

module Yamate

  class Backend
    KEEPALIVE_TIME = 15

    
    def initialize(app)
      @step = 0
      @app = app
      @clients = []

      if File.exists?('./conf/config.yml') then
        yamate_config = YAML.load_file('./conf/config.yml')
        @api_client = Yamate::APIClient.new(yamate_config["consumer_key"])
      else
        @api_client = Yamate::APIClient.new(ENV["CONSUMER_KEY"])
      end

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
        line_name         = train["odpt:lineName"]
        progress          = train["odpt:progress"]
        train_id          = train["@id"]
        from_station_name = train["odpt:fromStationName"]
        to_station_name   = train["odpt:toStationName"]
        @trains.push(Yamate::Train.new(train_id, from_station_name, to_station_name, progress, line_name))
      end
      @trains.each do |train|
        train.update
      end
    end

    def estimate_train_data()
      @trains.each do |train|
        train.estimate
        train.update
      end

    end
    
    def routine()
      if @step % 60 == 0 then
        puts "************ UPDATE *************"
        self.update_train_data
        @step = 0
      else
        puts "------------ ESTIMATE ------------"
        self.estimate_train_data
      end
      @step += 1

      # Preparing seding data
      data = {}
      data[:trains] = []
      @trains.each do |train|
        data[:trains].push(train.get_position)
      end
      sleep 1
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
