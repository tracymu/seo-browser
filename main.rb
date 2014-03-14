# If we wanted to take a URL and then just return in a browser an adjusted version of the html
# Do we need a database?
# I think maybe I don't need a database

# Need to remember to make sure it takes http:// if not, add it on.



require 'Nokogiri'
require 'open-uri'
require 'sinatra'
require 'data_mapper'



# url = "http://www.nokogiri.org"
# doc = Nokogiri::HTML(open(url))

# @title = doc.at_css("h2").text


DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/main.db")

class URL
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!

get '/' do
  @urls = URL.all
  erb :home
end

post '/' do
  u = URL.new
  u.content = params[:content]
  u.created_at = Time.now
  u.updated_at = Time.now
  u.save
  redirect '/results'
end


get '/results' do
  @url=URL.last
  UrlScrape()
  erb:results
end

def UrlScrape
  doc = Nokogiri::HTML(open(@url.content))
  @h1 = doc.at_css("h1").text
  @h2 = doc.at_css("h2").text
  @title = doc.at_css("title").text
end