# Libraries
require 'rubygems'
require 'sinatra/base'
require 'slim'
require 'sass'
require 'net/http'
require 'open-uri'
require 'xmlsimple'
require 'time-lord'

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
    client = LastFm.new
    user = 'chicohernando'

    top_artists = client.get_top_artists(user, 5)
    @top_artists = top_artists['topartists']['artist']

    recent_tracks = client.get_recent_tracks(user, 5)
    @recent_tracks = recent_tracks['recenttracks']['track']

    top_tracks = client.get_top_tracks(user, 5)
    @top_tracks = top_tracks['toptracks']['track']

    user_info = client.get_user_info(user)
    @user_info = user_info['user']

    @user_info['gender'] = user_gender(@user_info['gender'])

    @user_profile = user_url(user)

    slim :index
  end

  # TODO: find a place for view helpers
  def user_url(user)
    "http://last.fm/user/" + user
  end

  def user_gender(gender)
    gender == 'f' ? 'female' : 'male'
  end
end

class LastFm
  attr_reader :api_key

  def initialize(options = {})
    @http = Net::HTTP.new('ws.audioscrobbler.com')
    @api_key = 'nope'
  end

  def get_top_artists(username, limit, period = '7day')
    get "/2.0/?method=user.gettopartists&user=#{username}&api_key=#{@api_key}&limit=#{limit}&period=#{period}"
  end

  def get_recent_tracks(username, limit, from = nil)
    path = "/2.0/?method=user.getrecenttracks&user=#{username}&api_key=#{@api_key}&limit=#{limit}"
    path = path + "&from=#{from}" unless from.nil?
    get path
  end

  def get_top_tracks(username, limit, period = '7day')
    path = "/2.0/?method=user.gettoptracks&user=#{username}&api_key=#{@api_key}&limit=#{limit}"
    path = path + "&period=#{period}" unless period.nil?
    get path
  end

  def get_user_info(username)
    get "/2.0/?method=user.getinfo&user=#{username}&api_key=#{@api_key}"
  end

  private

  def get(url)
    response = @http.request(Net::HTTP::Get.new(url))
    XmlSimple.xml_in(response.body, { 'ForceArray' => false })
  end
end

if __FILE__ == $0
  MyApp.run! :port => 4567
end
