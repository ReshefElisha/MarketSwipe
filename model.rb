require 'rubygems'
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'bcrypt'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Swipe
  include DataMapper::Resource
  property :id,		Serial
  property :owner,		String, :required => true
  property :time,		DateTime
end

class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial, :key => true
  property :username, String, :length => 3..50
  property :password, BCryptHash
end

DataMapper.finalize
DataMapper.auto_migrate!
DataMapper.auto_upgrade!
Swipe.auto_migrate!
User.auto_migrate!
