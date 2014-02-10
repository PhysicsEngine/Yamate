# -*- coding: utf-8 -*-
require 'faye/websocket'
require 'json'
require 'Yamate'
require 'yaml'
require 'twitter'

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

        # For twitter search api
        api_key       = yamate_config["api_key"]
        api_secret    = yamate_config["api_secret"]
        access_token  = yamate_config["access_token"]
        access_secret = yamate_config["access_secret"]
        
      else
        @api_client = Yamate::APIClient.new(ENV["CONSUMER_KEY"])
        api_key       = ENV["TWITTER_API_KEY"]
        api_secret    = ENV["TWITTER_API_SECRET"]
        access_token  = ENV["TWITTER_ACCESS_TOKEN"]
        access_secret = ENV["TWITTER_ACCESS_SECRET"]
      end

      self.update_train_data

      @twitter_api_client = Twitter::REST::Client.new do |config|
        config.consumer_key        = api_key
        config.consumer_secret     = api_secret
        config.access_token        = access_token
        config.access_token_secret = access_secret
      end

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
        is_operation      = train["odpt:isInOperation"]
        train_number      = train["odpt:trainNumber"]
        delay             = train["odpt:delay"]
        @trains.push(Yamate::Train.new(train_id, from_station_name, to_station_name, progress, line_name, is_operation, train_number, delay))
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
      tweets = []
      if @step % 60 == 0 then
        @twitter_api_client.search("山手線", :lang => "ja", :result_type => "recent").take(400).collect do |tweet|
          Train.get_station_names.each do |station_name|
            if tweet.text.include?(station_name) then
              tweet_data = {:username => tweet.user.screen_name, :tweet => tweet.text, :station_name => station_name}
              tweets.push(tweet_data)
            end
          end
        end
        
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
      data[:tweets] = tweets
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
          #@clients.each do |client|
          #  client.send({ count: @clients.size }.to_json)
          #end
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
