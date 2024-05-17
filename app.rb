#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'blogg.db'
	@db.results_as_hash = true

end

before	do
	init_db
end

configure do
	init_db

	# Creating a table if it is not exists
	@db.execute 'CREATE TABLE IF NOT EXISTS
	post
	(id	INTEGER,
		created_date	DATE,
		post	TEXT,
		PRIMARY KEY(id AUTOINCREMENT)
	)'
end

# Function to receive results
def get_results
	@results = @db.execute 'select * from post order by id desc'
end
get '/index' do
	get_results

	erb :index
end

get '/new' do
	erb :new
end

post '/new' do
	@post = params[:post]

	if @post.length <= 0
		@error = 'Enter you text'
		return erb :new
	end

	@db.execute 'Insert into post (post,created_date) values (?, datetime())', [@post]
	get_results
	redirect to '/index'
end

get '/details/:mess' do
	post_id = params[:mess]

	results = @db.execute 'select * from post where id = ?', [post_id]
	@row = results[0]

	erb 'Must show posts for <b>' + post_id.to_s + '</b>'

	erb :details
end