
require 'Nokogiri'
require 'open-uri'
require 'sinatra'
require 'data_mapper'

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
  url = URL.new
  url.content = params[:content]
  url.created_at = Time.now
  url.updated_at = Time.now
  url.save
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
  meta_desc = doc.css("meta[name='description']").first

  if meta_desc
    @content = meta_desc['content']
  else
    @content = "This page has no description, Google will choose what content to show from your page, and it will be up to approx 155 characters long"
  end

  @body = doc.css("body")
  @links = doc.css("a")
  @link_list = @links.map { |link| link['href']}
  @total_links = @links.length

  @domain = @url.content.sub(/^https?\:\/\//, '').sub(/^www./,'')

  @external_links = []
  @internal_links =[]

  @link_list = @link_list.compact  #Some of the links were coming up not as strings, but as nil Class, so had to remove

  @link_list.each do |link|
    if link.include? @domain
      @internal_links << link
    elsif link.start_with? "http"
      @external_links << link
    end
  end
    @external_links.reject! { |link| link.empty? }
    @total_external_links = @external_links.length
end






###### NOTES AND QUESTIONS ####################

# Design Patterns for Sinatra apps- how to lay this out better - sinatra chassis

# Need to remember to make sure it takes http:// if not, add it on. i.e validating URL entries

# going to use Javascript to acordion up the entries

# How to be able to press enteri nstead of  have to click submit

# How to make it so the cursor is already in the box when you land on the page

# no follows

# Format like Google snippet

# canonical tag checker-

# Why aren't the params in the URL, and so I can just refresh?

# What happens if there is nothing at that page?

