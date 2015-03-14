require 'sinatra'
require 'slim'
require 'data_mapper'
require 'date'
require 'mail'

require './model'

module MarketSwipe
  class App < Sinatra::Base
    configure do
      enable :sessions
      Mail.defaults do
        delivery_method :smtp, {
        :port      => 587,
        :address   => "smtp.mandrillapp.com",
        :user_name => ENV["MANDRILL_USERNAME"],
        :password  => ENV["MANDRILL_PASSWORD"]
        }
      end
    end
    
    def logged_in?
      session[:pitt_id]
    end

    def alert
      session[:alert]
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

    get '/:confpass/:pittId' do
      curUser = User.first(:pitt_id => params[:pittId])
      if curUser and params[:confpass] == curUser.rand
        curUser[:confirmed]=true;
        session[:alert] = 'Your account has been confirmed, you may now log in'
      end
      redirect to('/')
    end

    get '/conf/:pittId' do
      sendConfirmEmail(params[:pittId])
      session[:alert] = 'Confirmation email sent. Please check your pitt.edu email for confirmation.'
      redirect to('/')
    end

    post '/signin' do
      user = params[:pitt_id]
      password = params[:password]
      curUser = User.first(:pitt_id => user)
      if curUser and curUser[:confirmed] and curUser.password == password
        session[:pitt_id] = user
        session[:alert] = nil
      elsif curUser and curUser[:confirmed]
        session[:alert] = 'Wrong password, please try again'
      elsif curUser
        session[:alert] = 'Your account isn\'t confirmed. Please check your email or click <a href="www.marketswipe.com/conf/'+user+'">here</a> to resend confirmation email.'
      end
      redirect to('/')
    end

    def sendConfirmEmail(rand, pittId)
      addr=pittId+'@pitt.edu'
      mail = Mail.deliver do
        to      addr
        from    'MarketSwipeMe <noreply@marketswipe.me>'
        subject 'Please confirm your email for MarketSwipe'

        html_part do
          content_type 'text/html; charset=UTF-8'
          body 'Please confirm your email address by clicking on <a href="www.marketswipe.me/'+rand+'/'+pittId+'">this link</a>.'
        end
       end
    end

    post '/signup' do
      user = params[:pitt_id]
      password = params[:password]
      rpassword = params[:rpassword]
      if !User.first(:pitt_id => user) and password == rpassword
        puts "New User!"
        puts params[:pitt_id]
        rand = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
        User.create(:pitt_id => user, :name => params[:name], :rand => rand, :password => password)
        sendConfirmEmail(rand, params[:pitt_id])
        session[:alert] = 'Your account has been created, please check your pitt email for confirmation'
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
