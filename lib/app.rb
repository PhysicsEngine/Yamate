require 'sinatra/base'
require 'haml'

module Yamate

  class App < Sinatra::Base

    use Rack::Auth::Basic, "Protected Area" do |username, password|
      username == ENV['USERNAME'] && password == ['USER_PASSWORD']
    end

    ['/', %r{^/\d+/?$}].each do |path|
      get path do
        send_file File.join(settings.public_folder, 'index.html')
      end
    end
  end
end
