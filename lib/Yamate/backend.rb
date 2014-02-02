require 'faye/websocket'
require 'json'

module Yamate
  class Train
    @@radius = 1
    
    def initialize(id, theta)
      @id    = id
      @x     = 0
      @y     = 0
      @theta = theta
    end

    def move()
      @theta += 0.01
      @x = @@radius * Math.cos(@theta)
      @y = @@radius * Math.sin(@theta)
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
      @trains  = []
      init_theta = Random.new()
      for i in 0..10 do
        @trains.push(Train.new(i, init_theta.rand))
      end
    end

    def routine()
      @trains.each do |train| 
        train.move
      end

      data = {}
      data[:trains] = []
      @trains.each do |train|
        data[:trains].push(train.get_position)
      end
      
      puts data.to_json
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
