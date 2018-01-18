require 'sinatra'
# require 'sinatra/reloader'
require 'pry'
require 'pg'
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
  @quotes = Quote.all.order(:id)

  # favourites count
  # counts = Hash.new 0
  # @top_quotes.each do |data|
  #   counts[data.quote_id] += 1
  # end
  # @top_quotes = Favourite.all.count{ |x| x.quote_id }
  erb :index
end

get '/about' do
  erb :about
end


#  profile
get '/profile' do
  redirect '/login' unless logged_in?

  # @result = Quote.where(user_id: current_user.id)

  conn = PG.connect(dbname: 'quote_app')
  sql_uploaded = "select id, user_id, category, author, content FROM quotes WHERE user_id = '#{current_user.id}';"
  @result = conn.exec(sql_uploaded)
  conn.close

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
  # @result = Quote.joins(:users)
  @result = Quote.where("content like ?", "%#{@search}%").or(Quote.where("author like ?", "%#{@search}%"))
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
  redirect '/'
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
    redirect '/'
  else
    erb :login
  end
end

delete '/session' do
  session[:user_id] = nil
  redirect '/'
end

