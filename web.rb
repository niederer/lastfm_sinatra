# Libraries
require 'rubygems'
require 'sinatra/base'
require 'slim'
require 'sass'

# Application
class SassHandler < Sinatra::Base
  set :views, File.dirname(__FILE__) + '/templates/sass'

  get '/css/*.css' do
    filename = params[:splat].first
    scss filename.to_sym
  end
end

class MyApp < Sinatra::Base
  use SassHandler

  # Configuration
  set :public_folder, File.dirname(__FILE__) + '/public'
  set :views, File.dirname(__FILE__) + '/views'

  # Route Handlers
  get '/' do
    slim :index
  end
end

if __FILE__ == $0
  MyApp.run! :port => 4567
end
