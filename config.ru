require 'app'
require 'Yamate/backend'

use Rack::Auth::Basic do |username, password|
  username == ENV['BASIC_AUTH_USERNAME'] && password == ENV['BASIC_AUTH_PASSWORD']
end

use Yamate::Backend

run Yamate::App
