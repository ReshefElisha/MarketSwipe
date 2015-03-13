require 'sinatra'
require 'slim'
require 'data_mapper'

require './model'

module MarketSwipe
  class App < Sinatra::Base

    attr_accessor :logged_in
    configure do
      @@logged_in = false
    end
    
    def logged_in
      @@logged_in
    end

    get '/' do
      #@@logged_in = !@@logged_in
      @swipes = Swipe.all
      slim :index
    end

    post '/signin' do
      @user = params[:pitt_id]
      @password = params[:password]
      @curUser = User.first(:username => @user)
      if @curUser and @curUser.password == @password
        @@logged_in = true
        puts "logged in!"
        
      end
      redirect to('/')
    end

    post '/signup' do
      @user = params[:pitt_id]
      @password = params[:password]
      @rpassword = params[:rpassword]
      if !User.first(:username => @user) and @password == @rpassword
        puts "New User!"
        puts @user
        User.create(:username => @user, :password => @password)
        redirect to('/')
      end
    end
  end
end
