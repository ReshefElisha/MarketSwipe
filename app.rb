require 'sinatra'
require 'slim'
require 'data_mapper'

require './model'

module MarketSwipe
  class App < Sinatra::Base
    configure do
      enable :sessions
    end
    
    def logged_in?
      session[:pitt_id]
    end

    get '/' do
      @swipes = Swipe.all
      slim :index
    end

    get '/signup' do
      slim :signup
    end

    post '/signin' do
      user = params[:pitt_id]
      password = params[:password]
      curUser = User.first(:pitt_id => user)
      puts curUser
      if curUser and curUser.password == password
        session[:pitt_id] = user
        puts "logged in!"
      end
      redirect to('/')
    end

    post '/signup' do
      user = params[:pitt_id]
      password = params[:password]
      rpassword = params[:rpassword]
      if !User.first(:pitt_id => user) and password == rpassword
        puts "New User!"
        puts session[:pitt_id]
        User.create(:pitt_id => user, :name => params[:name], :password => password)
      end
      redirect to('/')
    end
    
    post '/giveaway' do
      puts params[:datetimepickerFrom]
      Swipe.create(:owner => User.first(:pitt_id => session[:pitt_id]).name, :email => session[:pitt_id]+'@pitt.edu', :timeFrom => params[:timeFrom], :timeTo => params[:timeTo])
      redirect to('/')
    end
  end
end
