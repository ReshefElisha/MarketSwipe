source "https://rubygems.org"
gem 'sinatra'
gem 'slim'
gem 'data_mapper'
gem 'mail'
gem 'postmark'

group :production do
    gem "pg"
    gem "dm-postgres-adapter"
end

group :development, :test do
    gem "sqlite3"
    gem "dm-sqlite-adapter"
end
