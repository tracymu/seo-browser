require 'Nokogiri'
require 'open-uri'
require 'sinatra'
require 'data_mapper'
require 'uri/http'

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
  meta_desc = doc.css("meta[name='description']").first

  if meta_desc
    @content = meta_desc['content']
  else
    @content = "This page has no description, Google will choose what content to show from your page, and it will be up to approx 155 characters long"
  end

  @body = doc.css("body")
  @links = doc.css("a")
  @total_links = @links.length
  @external_links = @links.reject{|x| x["href"][0] == '/'}
  @external_links = @external_links.reject{|x| x["href"].include? @url.content}
  @external_links = @external_links.reject{|x| x["href"][0] == '#'}
    # # Is there a better way to do this than on multiple lines?
  # # Why is it working for some URLs (beat smh abc) and not others (vision moomux)
  @total_external_links = @external_links.length

end


# I want to use this method below to make it so that people can enter wierd URLs in and it will figure it out O
# Or should I just use validations?
# I was also thinking knowing the domain would help exclude internal links

# def DomainName(url)
#   uri = URI.parse(url)
#   domain = PublicSuffix.parse(uri.host).domain
# end




###### NOTES AND QUESTIONS ####################


# Use this to see about improving the way you get the links http://stackoverflow.com/questions/856706/extract-links-urls-with-nokogiri-in-ruby-from-a-href-html-tags

# then if you do a while loop to print them, you can use an if statement to skip over the ones you dont' want?

# Do we need a database? I think maybe I don't need a database

# Need to remember to make sure it takes http:// if not, add it on.

# How to be able to press enteri nstead of  have to click submit


# Obviously the file should probably not be set out like this.

# Make an array of all the things you don't want to include, like #, javascript, @url.content

# to get just the domain name, it must be something like if starts with http:// strip it off
# then if it starts with www. strip that off too.

# no follows

# internal links (i.e. where the link doesn't start with / or url)

# limit title characters to what Google sees

# Same as description

# Format like Google snippet

# canonical tag checker-

# How to get meta description out
# Why aren't the params in the URL, and so I can just refresh?

# need to make it so that .includ? @url.content is just the domain, not www. or http:, so that
# it can include subdomains

# Links to exclude are like this:
 # links_that_start_with = ['/','#',]
  # links_that_include = [@domain, 'javascript', 'void']

