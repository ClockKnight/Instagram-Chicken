# Homepage (Root path)
require "sinatra"
require "instagram"

enable :sessions

CALLBACK_URL = "http://localhost:3000/oauth/callback"

<<<<<<< HEAD
=======
# Login page
get '/login' do
  if session[:access_token] == nil 
    erb :'login'
  else
    erb :'user'
  end
end

# Category page
get '/category' do
  if session[:access_token] == nil 
    erb :'login'
  else
    erb :'category'
  end  
end





# Hatim's instagram key
# Instagram.configure do |config|
#   config.client_id = "233b809cbca8494b85743f13d81fa9b5"
#   config.client_secret = "87249927d0b04a03af10f7ad0d048075"
#   # For secured endpoints only
#   #config.client_ips = '<Comma separated list of IPs>'
# end

>>>>>>> master
Instagram.configure do |config|
  config.client_id = "4a9c8bcaff1b4b03901e20bb5777d8bd"
  config.client_secret = "1b574823e66d41dbbbb2a84b18646ddd"
  config.scope = "public_content likes"
  # For secured endpoints only
  #config.client_ips = '<Comma separated list of IPs>'
end

get "/" do
  redirect "/oauth/connect"
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  #session[:access_token] = "16384709.6ac06b4.49b97800d7fd4ac799a2c889f50f2587"
  create_user(Instagram.client(:access_token => session[:access_token]).user)
 # session[:user_id] = response[:id]
  @userid = response.user.id
  puts "------"
  puts response.inspect
  puts "-----"
  puts response.user.id
  #redirect "/nav"
  #redirect "/competing"
  erb :index
  
end

get "/home" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Winners</h1>"
  arr = []
  tags = client.tag_search('beatit_') # returns all tags that start with beatit_
  tags.each do |tag|
    if tag.name =~ /^beatit_[a-z]+/ 
      arr << tag.name
    end
  # arr.each do |tagname|
  #   puts tagname.length
  # end
  end 
  arr.uniq!
  puts arr
  @arrwinners = []
  arr.each do |x|
    
    tags = client.tag_search(x)
    tags.each do |tag|
        if tag.name =~ /^#{x}$/ 
          @arrwinners << tag
        end
    end 
   
    # html << "<h2>Tag Name = #{tags[0].name}. Media Count =  #{tags[0].media_count}. </h2><br/><br/>"
    # pictures = client.tag_recent_media(tags[0].name).sort!{|x,y| y.likes[:count] <=> x.likes[:count]}

    # html << "<div style='float:left;'><img src='#{pictures[0].images.thumbnail.url}'><br/> <a href='/media_like/#{pictures[0].id}'>Like</a>  <a href='/media_unlike/#{pictures[0].id}'>Un-Like</a>  <br/>LikesCount=#{pictures[0].likes[:count]}</div>" 
  end
  @arrwinners.uniq!
    
    @arrwinners.each do |element|
      pictures = client.tag_recent_media(element.name).sort!{|x,y| y.likes[:count] <=> x.likes[:count]}
      html << "<div style='float:left;'><img src='#{pictures[0].images.thumbnail.url}'><br/> <a href='/media_like/#{pictures[0].id}'>Like</a>  <a href='/media_unlike/#{pictures[0].id}'>Un-Like</a>  <br/>LikesCount=#{pictures[0].likes[:count]}</div>" 
    end 

html
end

get "/nav" do
  html =
  """
    <h1>Ruby Instagram Gem Sample Application</h1>
    <ol>
      <li><a href='/user_recent_media'>User Recent Media</a> Calls user_recent_media - Get a list of a user's most recent media</li>
      <li><a href='/user_media_feed'>User Media Feed</a> Calls user_media_feed - Get the currently authenticated user's media feed uses pagination</li>
      <li><a href='/location_recent_media'>Location Recent Media</a> Calls location_recent_media - Get a list of recent media at a given location, in this case, the Instagram office</li>
      <li><a href='/media_search'>Media Search</a> Calls media_search - Get a list of media close to a given latitude and longitude</li>
      <li><a href='/media_popular'>Popular Media</a> Calls media_popular - Get a list of the overall most popular media items</li>
      <li><a href='/user_search'>User Search</a> Calls user_search - Search for users on instagram, by name or username</li>
      <li><a href='/location_search'>Location Search</a> Calls location_search - Search for a location by lat/lng</li>
      <li><a href='/location_search_4square'>Location Search - 4Square</a> Calls location_search - Search for a location by Fousquare ID (v2)</li>
      <li><a href='/tags'>Tags</a>Search for tags, view tag info and get media by tag</li>
      <li><a href='/limits'>View Rate Limit and Remaining API calls</a>View remaining and ratelimit info.</li>
    </ol>
  """
  html
end


get "/competing" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user
  html = ""
  html << "<h1>#{user.username}'s WINS': </h1>"
  html << "<h1>#{user.username} is competing in: </h1>"
  html << "<h1>#{user.bio} bio</h1>"
  for media_item in client.user_recent_media
      puts media_item.tags
      media_item.tags.each do |tag|
        if tag =~ /^beatit_[a-z]+/ 
          html << "<div style='float:left;'><strong>##{tag}<strong><img src='#{media_item.images.thumbnail.url}'><br/> <a href='/media_like/#{media_item.id}'>Like</a>  <a href='/media_unlike/#{media_item.id}'>Un-Like</a>  <br/>LikesCount=#{media_item.likes[:count]}</div>"
        end
      end
  end
  html
end

get '/media_like/:id' do
  client = Instagram.client(:access_token => session[:access_token])
  client.like_media("#{params[:id]}")
  redirect "/user_recent_media"
end

get '/media_unlike/:id' do
  client = Instagram.client(:access_token => session[:access_token])
  client.unlike_media("#{params[:id]}")
  redirect "/user_recent_media"
end

get "/user_media_feed" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user
  html = "<h1>#{user.username}'s media feed</h1>"

  page_1 = client.user_media_feed(777)
  page_2_max_id = page_1.pagination.next_max_id
  page_2 = client.user_recent_media(777, :max_id => page_2_max_id ) unless page_2_max_id.nil?
  html << "<h2>Page 1</h2><br/>"
  for media_item in page_1
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html << "<h2>Page 2</h2><br/>"
  for media_item in page_2
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html
end

get "/location_recent_media" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Media from the Instagram Office</h1>"
  for media_item in client.location_recent_media(514276)
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html
end

get "/media_search" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Get a list of media close to a given latitude and longitude</h1>"
  for media_item in client.media_search("51.0486","114")
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html
end

get "/media_popular" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Get a list of the overall most popular media items</h1>"
  for media_item in client.media_popular
    html << "<img src='#{media_item.images.thumbnail.url}'>"
  end
  html
end

get "/user_search" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Search for users on instagram, by name or usernames</h1>"
  for user in client.user_search("instagram")
    html << "<li> <img src='#{user.profile_picture}'> #{user.username} #{user.full_name}</li>"
  end
  html
end

get "/location_search" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Search for a location by lat/lng with a radius of 5000m</h1>"
  for location in client.location_search("48.858844","2.294351","5000")
    html << "<li> #{location.name} <a href='https://www.google.com/maps/preview/@#{location.latitude},#{location.longitude},19z'>Map</a></li>"
  end
  html
end

get "/location_search_4square" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Search for a location by Fousquare ID (v2)</h1>"
  for location in client.location_search("3fd66200f964a520c5f11ee3")
    html << "<li> #{location.name} <a href='https://www.google.com/maps/preview/@#{location.latitude},#{location.longitude},19z'>Map</a></li>"
  end
  html
end

get "/tags" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1>Search for tags, get tag info and get media by tag</h1>"
  tags = client.tag_search('beatit_computer')
  html << "<h2>Tag Name = #{tags[0].name}. Media Count =  #{tags[0].media_count}. </h2><br/><br/>"
  pictures = client.tag_recent_media(tags[0].name).sort!{|x,y| y.likes[:count] <=> x.likes[:count]}
  for media_item in pictures
    html << "<div style='float:left;'><img src='#{media_item.images.thumbnail.url}'><br/> <a href='/media_like/#{media_item.id}'>Like</a>  <a href='/media_unlike/#{media_item.id}'>Un-Like</a>  <br/>LikesCount=#{media_item.likes[:count]}</div>"  end
  len = client.tag_search(tags[0].name).length
  html << "#{len}"
  html
  #erb :'/index'
end

get "/limits" do
  client = Instagram.client(:access_token => session[:access_token])
  html = "<h1/>View API Rate Limit and calls remaining</h1>"
  response = client.utils_raw_response
  html << "Rate Limit = #{response.headers[:x_ratelimit_limit]}.  <br/>Calls Remaining = #{response.headers[:x_ratelimit_remaining]}"
  html
end

helpers do
  def create_user(user)
    data_user = User.find_by(instagram_user_id: user.id.to_i)
    unless user
      data_user = User.create(username: user.username , full_name: user.full_name , instagram_user_id: user.id.to_i, 
                  profile_picture: user.profile_picture , bio: user.bio, website: user.website)
    end 
    data_user
  end

  def loged_in?
    !session[:access_token].nil?
  end
end
