class OrdersController < ApplicationController
	require 'json'	
	before_action :logged
	before_action :latestorder, only:[:new]
	# def index 
	# 	@current_user
	# 	@product=Product.all
	# 	@order =Order.new
	# end

	def new

		# if logged_in?
		# 	puts "uid"	
			# puts @current_user.id
		@product=Product.where("status = true")
		
		@order = Order.new
	end

	def create
		puts "-----------------Save Order---------------"
		puts orderProducts
		@oproducts=JSON.parse orderProducts['products']
		if @current_user.id != 1
			# @user = User.find(@current_user.id)
			@ouser = @current_user.id
		else
			@ouser = orderProducts['usr']
		end

		@order = Order.create(notes: orderProducts['notes'], room: orderProducts['room'],user_id: @ouser,status:"Processing")
		
		if @order.save
			if @oproducts != nil
				@oproducts.each{ |oprod|
					@order_products=OrderProduct.create(order: @order, product_id: oprod["id"], quantity: oprod["quantity"])
				}
			end
			# reload page
			 @product=Product.where("status = true")
			#####################List latest order#########################
			@latest_order=Order.last
			@lorder_products=OrderProduct.find_by_sql("SELECT * FROM order_products WHERE order_id = "+@latest_order.id.to_s)
			@lorderdata=[]
			@lorder_products.each{ |lop|
				@lorder_product=Product.find(lop.product_id)
				@lorderdata << { "pimg" => @lorder_product.image.url(:thumb), "pname" => @lorder_product.name}
			}
			##############################################
			
			render :new
		end
	end
	#List admin orders page
	def list
		
		@orderdata=[]
		puts "++++++++++++++++++++++++++++++++++"
		if @current_user.id == 1
			@orders= Order.all
			@orders.each { |order| 
				 # puts order.created_at
				@user=User.find(order.user_id)
				@orderdata << {"oid" => order.id, "odate" => order.created_at,"ostatus" => order.status,"uname" => @user.name ,"uroom" => @user.room,"uext" => @user.ext_room}
			}
			render 'list'
		else
			# List user My order page
			@orders= Order.where(user_id: @current_user.id)
			@orders.each { |order| 
				@amount=0
				@order_products_ids=OrderProduct.find_by_sql("SELECT * FROM order_products WHERE order_id = "+order.id.to_s)
				@order_products_ids.each{ |op|
					@pprice=Product.select(:price).where(id: op.product_id)
					@amount+=@pprice[0].price*op.quantity
				}
				@orderdata << {"oid" => order.id, "odate" => order.created_at,"ostatus" => order.status,"oamount" => @amount}
			}
			render 'myorders'

		end

	end

	# delet order page
	def destroy
		@order=Order.find(params[:oid])
    	@order.destroy
    	redirect_to :back
  	end



	#change order status
	def deliver
		puts "+++++++++++++oid++++++++++++++"
		puts params[:oid]
		@order = Order.find(params[:oid])
		@order.update(status: "out for delivery")
		puts "+++++++++++++oid++++++++++++++"
		redirect_to :back
	end

	#display order products
	def orderproductlist
		puts "+++++++++++++oid++++++++++++++"
		@orderproductsids=OrderProduct.find_by_sql("SELECT * FROM order_products WHERE order_id = "+orderidfromlist["oid"])
		puts @orderproductsids.inspect
		@orderproducts=[]
		@orderproductsids.each{ |op|
			@product=Product.find(op.product_id)
			@orderproducts << {"quantity" => op.quantity, "pimg" => @product.image.url(:thumb), "pname" => @product.name, "pprice" => @product.price}
		}
		puts "+++++++++++++++++++++++full++++++++++++++++++++++++++"
		puts @orderproducts.inspect
		render :json => @orderproducts
	end

	#filter user orders by date
	def datefilter
		@orderdata=[]	
  		@orders = Order.where("user_id = :uid AND created_at BETWEEN :start_date AND :end_date",
   			{uid: @current_user.id, start_date: params[:start_date].to_date.beginning_of_day, end_date: params[:end_date].to_date.end_of_day})	
  				
  		@orders.each { |order| 
				@amount=0
				@order_products_ids=OrderProduct.find_by_sql("SELECT * FROM order_products WHERE order_id = "+order.id.to_s)
				@order_products_ids.each{ |op|
					@pprice=Product.select(:price).where(id: op.product_id)
					@amount+=@pprice[0].price*op.quantity
				}
				@orderdata << {"oid" => order.id, "odate" => order.created_at,"ostatus" => order.status,"oamount" => @amount}
			}
		render 'myorders'	

	end

	# Checks page
	def checks
		if @current_user.id == 1
			@users=User.where("id != 1")	
			@uorderdata=[]
			@users.each { |user|
				puts "============================================"
				@amount=0
				@uorders=Order.find_by_sql("SELECT * FROM orders WHERE user_id = "+user.id.to_s)
				 puts @uorders.inspect	
				@uorders.each{ |uorder|
					if uorder != nil
						@order_products_ids=OrderProduct.find_by_sql("SELECT * FROM order_products WHERE order_id = "+uorder.id.to_s)
						@order_products_ids.each{ |op|
							@pprice=Product.select(:price).where(id: op.product_id)
							@amount+=@pprice[0].price*op.quantity
						}
				 		
				 	end
				 }
				@uorderdata << {"uid" => user.id,"uname" => user.name ,"amount" => @amount}
			}
			render 'checks'
		end
	end
	#display user order
	def userorderlist
		@userorder=[]
		# useridfromchecks
		@userorders=Order.find_by_sql("SELECT * FROM orders WHERE user_id = "+useridfromchecks["usid"])
		
		@userorders.each{ |uorder|
			@total =0
			if uorder != nil
				@order_products_ids=OrderProduct.find_by_sql("SELECT * FROM order_products WHERE order_id = "+uorder.id.to_s)	
				@order_products_ids.each{ |op|
					@pprice=Product.select(:price).where(id: op.product_id)
					@total+=@pprice[0].price*op.quantity
				}
				@userorder << {"oid" => uorder.id, "odate" => uorder.created_at,"amount" => @total}
			end
		}
		puts @userorder.inspect
		render :json => @userorder
	end

	#user filteration in check page
	def userfilter
		if @current_user.id == 1
			# puts  useridfilterchecks['id']
			@uid =useridfilterchecks['id']
			@users=User.where(id: @uid)	
			@uorderdata=[]
			 @users.each { |user|
				puts "========================ddsd===================="
				@amount=0
				@uorders=Order.find_by_sql("SELECT * FROM orders WHERE user_id = "+@uid)
				 puts @uorders.inspect	
				@uorders.each{ |uorder|
					if uorder != nil
						@order_products_ids=OrderProduct.find_by_sql("SELECT * FROM order_products WHERE order_id = "+uorder.id.to_s)
						@order_products_ids.each{ |op|
							@pprice=Product.select(:price).where(id: op.product_id)
							@amount+=@pprice[0].price*op.quantity
						}
				 		
				 	end
				}
				@uorderdata << {"uid" => @uid,"uname" => user.name ,"amount" => @amount}
				
			}
			render 'checks'
		end
	end

	def orderProducts
		params.permit(:room, :products, :notes, :usr)
	end
	def orderidfromlist
		params.permit(:oid)
	end
	def useridfromchecks
		params.permit(:usid)
	end
	def useridfilterchecks
		params.require(:user).permit(:id)
	end

	def latestorder
		@latest_order=Order.last
		if @latest_order != nil

			@lorder_products=OrderProduct.find_by_sql("SELECT * FROM order_products WHERE order_id = "+@latest_order.id.to_s)
			@lorderdata=[]
			@lorder_products.each{ |lop|
				@lorder_product=Product.find(lop.product_id)
				@lorderdata << { "pimg" => @lorder_product.image.url(:thumb), "pname" => @lorder_product.name}
			}
		end
	end

def logged
	notlogged
end
end