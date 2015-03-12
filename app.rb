require 'sinatra'
require 'slim'

module MarketSwipe
  class App < Sinatra::Base
	def swipes
	swipes = [Swipe.new, Swipe.new]
	swipes
	end

	get '/' do
	  slim :index
	end

	class Swipe
	  def initialize(owner = User.new("rhe8","Reshef Elisha"), time = "000000")
		@owner = owner
		@time = time
	  end
	  
	  attr_reader :owner
	  attr_reader :time
	end

	class User
	  def initialize(pittUname, fullName)
		@pittUname = pittUname
		@fullName = fullName
	  end
	  attr_reader :pittUname
	  attr_reader :fullName
	end
  end
end