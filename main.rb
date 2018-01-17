require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'
require_relative 'db_config'
require_relative 'models/user'
require_relative 'models/quote'

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
  erb :index
end

#  profile
get '/profile' do
  conn = PG.connect(dbname: 'quote_app')
  sql = "select * FROM quotes WHERE user_id = '#{current_user.id}';"
  @result = conn.exec(sql)
  # binding.pry
  conn.close
  erb :profile
end


# creating, editing, deleting quotes~~~~~~
# new quote page
get '/quote/new' do
  erb :new
end

# search quotes
get '/results' do
  search = params[:search]
  conn = PG.connect(dbname: 'quote_app')
  sql = "select category, author, content FROM quotes WHERE content LIKE '%#{search}%' OR author like '%#{search}%';"
  # sql = "insert into dishes(name, image_url) values ('#{params[:name]}','#{params[:image_url]}');"
  @result = conn.exec(sql)
  # binding.pry
  conn.close
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
  #  delete dish
  quote = Quote.find(params[:id])
  quote.delete
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
  redirect '/login'
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



