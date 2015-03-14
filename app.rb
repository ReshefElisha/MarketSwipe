require 'sinatra'
require 'slim'
require 'data_mapper'
require 'date'

require './model'

module MarketSwipe
  class App < Sinatra::Base
    configure do
      enable :sessions
    end
    
    def logged_in?
      session[:pitt_id]
    end
    
    def pruneSwipes
      swipes = Swipe.all
      timeNow = DateTime.strptime(DateTime.now.new_offset(-4.0/24).strftime('%m/%d/%Y %l:%M %p'), '%m/%d/%Y %l:%M %p')
      if swipes      
        for swipe in swipes
          if swipe[:timeTo] < timeNow
            Swipe.get(swipe[:id]).destroy
          end
        end
      end
    end

    get '/' do
      pruneSwipes
      @swipes = Swipe.all.sort_by {|vn| vn[:timeFrom]}
      slim :index
    end

    get '/signup' do
      slim :signup
    end

    post '/logout' do
      session[:pitt_id] = nil
      redirect to('/')
    end

    post '/signin' do
      user = params[:pitt_id]
      password = params[:password]
      curUser = User.first(:pitt_id => user)
      if curUser and curUser.password == password
        session[:pitt_id] = user
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
      Swipe.create(:owner => User.first(:pitt_id => session[:pitt_id]).name, :email => session[:pitt_id]+'@pitt.edu', :timeFrom => DateTime.strptime(params[:timeFrom], '%m/%d/%Y %l:%M %p'), :timeTo => DateTime.strptime(params[:timeTo], '%m/%d/%Y %l:%M %p'))
      redirect to('/')
    end
  end
end
