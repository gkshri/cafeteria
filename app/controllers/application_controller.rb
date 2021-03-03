class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # layout "users_header"

  layout "admin_header" #, except: :'sessions#new'
  
  def notlogged
	  if !logged_in?
	  	puts "sorry"
	  	redirect_to login_path, notice: 'you are not authorized!'
	  end
  end

  helper_method :auth

	def logged_in?
	  @current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	helper_method :logged_in?

end
