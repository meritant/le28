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

	# Creating POST table if it is not exists
	@db.execute 'CREATE TABLE IF NOT EXISTS
	post
	(id	INTEGER,
		created_date	DATE,
		post	TEXT,
		PRIMARY KEY(id AUTOINCREMENT)
	)'

	# Creating a table if it is not exists for COMMENTS
	@db.execute 'CREATE TABLE IF NOT EXISTS
	comment
	(id	INTEGER,
		created_date	DATE,
		post	TEXT,
		post_id integer,
		PRIMARY KEY(id AUTOINCREMENT)
	)'
end

# Function to receive results
def get_results
	@results = @db.execute 'select * from post order by id desc'
end

get '/' do
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

get '/details/:mess_id' do

	# Get variable from url
	post_id = params[:mess_id]

	results = @db.execute 'select * from post where id = ?', [post_id]
	@row = results[0]

	@results_comm = @db.execute 'select * from comment where post_id = ? order by id desc', [post_id]


	# Return data to detail.erb
	erb :details
end

post '/details/:mess_id' do
	# Get mess id from url
	post_id = params[:mess_id]
	# Get message from the form
	content = params[:comment]

	# Validating for empty post

	if content.length <= 0
		@error = 'Enter comments'

		redirect to '/details/' + post_id

	end
	@db.execute 'Insert into comment (post, created_date,post_id) values (?, datetime(), ?)', [content, post_id]

	redirect to '/details/' + post_id
end