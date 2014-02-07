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
end
