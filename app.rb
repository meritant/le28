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

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"
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

	erb  "You wrote #{@post}"
end