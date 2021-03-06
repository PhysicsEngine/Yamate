require 'sinatra/base'
require 'haml'

module Yamate

  class App < Sinatra::Base

    # If you want to add Basic authentification, comment in this
    use Rack::Auth::Basic, "Protected Area" do |username, password|
      username == ENV['BASIC_AUTH_USERNAME'] && password == ENV['BASIC_AUTH_PASSWORD']
    end

    ['/', %r{^/\d+/?$}].each do |path|
      get path do
        send_file File.join(settings.public_folder, 'index.html')
      end
    end
  end
end
