class UsersController < ApplicationController

before_action :logged
before_action :user_data, only:[:edit, :update,:destroy]

	def index
		@user = User.all.paginate(page: params[:page], per_page: 5)
	end
	def new
		@user = User.new
	end

	def create

		@user=User.create(user_params)
		if @user.save
			redirect_to users_path
		else
			render 'new'
		end
	end
	def edit
    
  	end

  	def update
    
	    if @user.update(user_params)
	      redirect_to users_path
	    else
	      render 'edit'
	    end
  	end

  	def destroy
  		
    	@user.destroy
    	redirect_to users_path
  	end

def user_params
  params.require(:user).permit(:name, :email,:password, :password_confirmation, :room, :ext_room,:image)
end

def user_data
	@user = User.find(params[:id])
end
def logged
	notlogged
end
end
