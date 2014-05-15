
require 'Nokogiri'
require 'open-uri'
require 'sinatra'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/main.db")



DataMapper.finalize.auto_upgrade!

get '/' do
  erb :home
end

post '/' do

  redirect '/results'
end


get '/results' do
  @url=params[:content]
  UrlScrape()
  erb:results
end




def UrlScrape
  doc = Nokogiri::HTML(open(@url))
  @h1_array = doc.css('h1')
  @h1_num = @h1_array.length
  @h2_array = doc.css('h2')
  @h2_num = @h2_array.length
  @h3_array = doc.css('h3')
  @h3_num = @h3_array.length
  @h4_array = doc.css('h4')
  @h4_num = @h4_array.length
  @h5_array = doc.css('h5')
  @h5_num = @h5_array.length
  @h6_array = doc.css('h6')
  @h6_num = @h6_array.length



  if doc.at_css("link[rel='canonical']")
    @canonical = doc.at_css("link[rel='canonical']")['href']
  else
    @canonical = "There is no canonical tag on this page"
  end

  @title = doc.at_css("title").text

  meta_desc = doc.css("meta[name='description']").first
  if meta_desc
    @content = meta_desc['content']
  else
    @content = "This page has no description, Google will choose what content to show from your page, and it will be up to approx 155 characters long"
  end

  # @body = doc.css("body")
  @links = doc.css("a")
  @link_list = @links.map { |link| link['href']}
  @total_links = @links.length

  @domain = @url.sub(/^https?\:\/\//, '').sub(/^www./,'')

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

# How to be able to press enteri nstead of  have to click submit

# How to make it so the cursor is already in the box when you land on the page

# no follows

#  how to make a generic "This didn't work " page? for if page no good, or url wierd?

# Take all css inline and put in separate file

#at some point consider whether the chevron can go up and down http://stackoverflow.com/questions/13778703/adding-open-closed-icon-to-twitter-bootstrap-collapsibles-accordions
# Why aren't the params in the URL, and so I can just refresh?

# What happens if there is nothing at that page?

# For example with Twitte,r it does some https redirect and breaks the whole thing,

# I think maybe in bootstrap there is something which makes me enter http in the url box?
# because I specified url?
# however, if the url is weird or dodge, it will break. How do I show them "Sorry, this is not a valid url" flash message?

# If there is no web page there -do what?
# If there is no title? then what?

# Something about injections of dodgy html? http://code.tutsplus.com/tutorials/singing-with-sinatra-the-encore--net-19364
