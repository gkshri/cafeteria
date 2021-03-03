class PasswordResetsController < ApplicationController
  def new
  end

  def create
	user = User.find_by_email(params[:email])
	if user
	  flash[:notice] = 'E-mail sent with password reset instructions.'
	  redirect_to new_session_path
	else
	  flash[:notice] = 'E-mail not found.'
	  redirect_to :back
	end

  end

end
