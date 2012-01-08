['sinatra', 'data_mapper', 'haml'].each{|x| require x}

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/wish-list.db")  
  
class Person
  include DataMapper::Resource  
  property :id, Serial
	property :username, String, :required => true, :unique => true
  property :name, String, :required => true

	has n, :things, {:through => DataMapper::Resource}
end

class Thing
  include DataMapper::Resource  
  property :id, Serial
	property :name, String, :required => true, :unique => true
  property :description, String 
  property :link, String

	has n, :people, {:through => DataMapper::Resource, :required => false}
end
  
DataMapper.finalize.auto_upgrade! 

get '/' do
	redirect '/people'
end

### PEOPLE ###

get '/person/:id' do
	@person = Person.get(params[:id])
	@things = @person.things
	haml :person
end

get '/people' do
	@people = Person.all
	haml :people
end

post '/add_person' do
	person = Person.new
	person.username = params[:username]
	person.name = params[:name]
	person.save
	redirect '/people'
end

### THINGS ###

get '/thing/:id' do
	@thing = Thing.get(params[:id])
	haml :thing
end

get '/things' do
	@people = Person.all
	@things = Thing.all
	p @things
	haml :things
end

post '/add_thing' do
	thing = Thing.new
	thing.name = params[:name]
	thing.description = params[:description]
	thing.link = params[:link]
	thing.save
	redirect '/things'
end

post '/add_to_wishlist' do
	thing = Thing.get(params[:thing_id])
	person = Person.get(params[:person_id])
	person.things << thing
	person.save
	redirect back
end
