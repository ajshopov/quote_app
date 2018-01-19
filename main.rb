require 'sinatra'
# require 'sinatra/reloader'
require 'pry'
# require 'pg'
require_relative 'db_config'
require_relative 'models/user'
require_relative 'models/quote'
require_relative 'models/favourite'

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user_id])
  end

  def logged_in?
    !!current_user
  end
end

#  home
get '/' do
  quotes_with_favs = []
  @quotes = Quote.all.includes(:favourites)
  @quotes.each do |quote|
    quotes_with_favs.push({quote_id: quote.id, favs: quote.favourites.count})
  end
  @top_five = quotes_with_favs.max_by(5) {|quote| quote[:favs]}.map { |quote|
    quote[:quote_id]
  }
  # @quotes_to_show = @quotes.where(id: @top_five)
  @quotes_to_show = []
  @top_five.each do |ordered_id|
    @quotes_to_show.push(@quotes.where(id: ordered_id))
  end


  # binding.pry
  # # favourites count
  # top_quotes = Favourite.all
  
  # top_quotes.each do |favourite|
  #    count[favourite.quote_id] += 1
  # end
  # # ^^ gives {13 => 2, 9 => 1, etc}
  # @favs_array = count.sort_by{|k,v| v}
  # # binding.pry

  # @pos1 = Quote.find(@favs_array[-1][0])
  # @pos2 = Quote.find(@favs_array[-2][0])
  # @pos3 = Quote.find(@favs_array[-3][0])
  # @pos4 = Quote.find(@favs_array[-4][0])
  # @pos5 = Quote.find(@favs_array[-5][0])
  erb :index
end

get '/about' do
  erb :about
end


#  profile
get '/profile' do
  redirect '/login' unless logged_in?

  @result = Quote.where(user_id: current_user.id)

  # conn = PG.connect(dbname: 'quote_app')
  # sql_uploaded = "select id, user_id, category, author, content FROM quotes WHERE user_id = '#{current_user.id}';"
  # @result = conn.exec(sql_uploaded)
  # conn.close

  @fav = Favourite.where(user_id: current_user.id)
  # binding.pry
  erb :profile
end


# creating, editing, deleting quotes~~~~~~
# new quote page
get '/quote/new' do
  redirect '/login' unless logged_in?
  erb :new
end

# search quotes
get '/results' do
  @search = params[:search]
  @result = Quote.where("content ilike ?", "%#{@search}%").or(Quote.where("author ilike ?", "%#{@search}%").or(Quote.where("category ilike ?", "%#{@search}%")))
  if logged_in?
  @user_favs = Favourite.where(user_id: current_user.id)
  end
   # binding.pry
  erb :results
end

# create new quote
post '/quote' do
  quote = Quote.new
  # user_id, cat, author, text
  quote.user_id = current_user.id
  quote.author = params[:author]
  quote.category = params[:category]
  quote.content = params[:content]
  quote.save
  redirect '/profile'
end

get '/quote/:id/edit' do
  # edit page
  @quote = Quote.find(params[:id])
  erb :edit
end

put '/quote/:id' do
  # editing quote
  quote = Quote.find(params[:id])
  quote.author = params[:author]
  quote.category = params[:category]
  quote.content = params[:content]
  quote.save
  redirect "/quote/#{params[:id]}/edit"
end

delete '/quote/:id' do
  #  delete quote
  quote = Quote.find(params[:id])
  quote.favourites.destroy_all
  quote.delete
  redirect '/profile'
end

# adding to and removing from favourites
#add to favourites
post '/favourite/:id' do
  redirect '/login' unless logged_in?
  favourite = Favourite.new
  favourite.quote_id = Quote.find(params[:id]).id
  favourite.user_id = current_user.id
  # binding.pry
  favourite.save
  redirect back
end

delete '/favourite/:id' do
  favourite = Favourite.find(params[:id])
  favourite.delete
  redirect '/profile'
end

# login routes ~~~~~~~~~~~~~
get '/login' do
  erb :login
end

post '/newuser' do
  user = User.new
  user.username = params[:username]
  user.email = params[:email]
  user.password = params[:password]
  user.save
  redirect '/register'
end

get '/register' do
  erb :register
end

post '/session' do
  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    redirect '/profile'
  else
    erb :login
  end
end

delete '/session' do
  session[:user_id] = nil
  redirect '/'
end

