require 'rubygems'
require 'data_mapper'
require 'bcrypt'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Swipe
  include DataMapper::Resource
  property :id,         Serial
  property :owner,      String
  property :email,      String
  property :timeFrom,   DateTime
  property :timeTo,     DateTime
end

class User
  include DataMapper::Resource
  include BCrypt
  property :id,       Serial, :key => true
  property :pitt_id,  String, :length => 3..10
  property :name,     String
  property :password, BCryptHash
end

DataMapper.finalize
DataMapper.auto_upgrade!
