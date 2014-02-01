require 'sinatra/base'
require 'haml'

module Yamate
  class App < Sinatra::Base
    get "/" do
      haml :index
    end
  end
end
