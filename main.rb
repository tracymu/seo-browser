# If we wanted to take a URL and then just return in a browser an adjusted version of the html
# Do we need a database?
# I think maybe I don't need a database

# Need to remember to make sure it takes http:// if not, add it on.
# loops through all the elements - e.g all the h2s, or whatever.
# how to do it, with just
# read more about nokogiri
# get html, then find/replacing.
# Press enteri nstead of submit



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
  @h1_array = doc.css('h1')
  @h2_array = doc.css('h2')
  @h3_array = doc.css('h3')
  @h4_array = doc.css('h4')
  @h5_array = doc.css('h5')
  @h6_array = doc.css('h6')
  @title = doc.at_css("title").text
  @body = doc.css("body")
  @links = doc.css("a")
  @total_links = @links.length
  @external_links = @links.reject{|x| x["href"][0] == '/'}
  @external_links = @external_links.reject{|x| x["href"].include? @url.content}
  @external_links = @external_links.reject{|x| x["href"][0] == '#'}
  # # Is there a better way to do this than on multiple lines?
  # # Why is it working for some URLs (beat smh abc) and not others (vision moomux)
  # @total_external_links = @external_links.length

# Make an array of all the things you don't want to include, like #, javascript, @url.content

# to get just the domain name, it must be something like if starts with http:// strip it off
# then if it starts with www. strip that off too.

# no follows

# internal links (i.e. where the link doesn't start with / or url)

# limit title characters to what Google sees

# Same as description

# Format like Google snippet

# canonical tag checker-

# need to make it so that .includ? @url.content is just the domain, not www. or http:, so that
# it can include subdomains



end


# Ask someone how they would actually set all this out.

