
require 'Nokogiri'
require 'open-uri'
require 'sinatra'

get '/' do
  erb :home
end

post '/results' do
  @url = params[:url]
  @doc = scrape_page(@url)
  erb:results
end

private

def scrape_page(url)
  Nokogiri::HTML(open(url))
end

def h_tags(n)
  @doc.css("h#{n}").map &:text
end

def canonical_link
  canonical = @doc.at_css("link[rel='canonical']")
  canonical['href'] if canonical
end

def meta_title
  @doc.at_css("title").text
end

def meta_description
  meta_desc = @doc.at_css("meta[name='description']")
  meta_desc['content'] if meta_desc
end

def links
  @doc.css("a").map #&:href
end

def domain_name(url)
  uri = URI.parse(url)
  uri.host
end

def is_local(url)
  domain_name(url) == domain_name(@url)
end

def internal_links
  links.select #&:is_local
end

def external_links
  links.reject #&:is_local
end


###### NOTES AND QUESTIONS ####################

# this is a lot slower now?!
#All my "Except this, that tand the other" type of links is gone

# @content = "This page has no description, Google will choose what content to show from your page, and it will be up to approx 155 characters long"
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
