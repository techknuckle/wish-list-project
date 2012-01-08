['sinatra', 'data_mapper', 'haml'].each{|x| require x}

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/wish-list.db")  
  
class Person
  include DataMapper::Resource  
  property :id, Serial
	property :username, String, :required => true, :unique => true
  property :name, String, :required => true

	has n, :wantedthings
	has n, :things, {:through => :wantedthings}
end

class Thing
  include DataMapper::Resource  
  property :id, Serial
	property :name, String, :required => true, :unique => true
  property :description, String 
  property :link, String

	has n, :wantedthings
	has n, :things, {:through => :wantedthings}
end

class Wantedthing
  include DataMapper::Resource  
  property :id, Serial

	belongs_to :person
	belongs_to :thing
end
  
DataMapper.finalize.auto_upgrade! 

enable :sessions

before do
  @all_people = Person.all
  @current_user = session[:current_user]
end

post '/switch_person' do
  session[:current_user] = Person.get(params[:person_id])
  redirect back
end

get '/' do
	redirect '/people'
end

### PEOPLE ###

get '/person/:id' do
	@person = Person.get(params[:id])
	@things = @person.things
	p @things
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
	wantedthing = Wantedthing.create(:thing => thing, :person => person)
	person.wantedthings << wantedthing
	thing.wantedthings << wantedthing
	person.save
	thing.save
	redirect back
end
