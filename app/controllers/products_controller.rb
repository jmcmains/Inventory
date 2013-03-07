class ProductsController < ApplicationController

	def new
		@product = Product.new
		@title = "New Product"
	end

	def create
		@product = Product.new(params[:product])
    @product.save
    redirect_to products_path
	end
	
	def cogs
		@product = Product.find(params[:id])
    @title = @product.name
    if params[:start_date]
  		@start_date = Date.new(params[:start_date][:year].to_i,params[:start_date][:month].to_i,params[:start_date][:day].to_i)
  		@end_date = Date.new(params[:end_date][:year].to_i,params[:end_date][:month].to_i,params[:end_date][:day].to_i)
  	else
  		@start_date = Date.today.beginning_of_year
  		@end_date = Date.today.end_of_year
  	end
  	if Rails.env.production?
			sql = ActiveRecord::Base.connection()
			d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity) as purchases FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (products.id = #{@product.id}) AND orders.date <= '#{@end_date}'::date AND orders.date >= '#{@start_date}'::date")
			purchases=d[0]["purchases"].to_i
			d=sql.execute("SELECT product_counts.count as count, product_counts.is_box as box, events.id as id, product_counts.price as price from product_counts INNER JOIN events ON events.id = product_counts.event_id WHERE (product_counts.product_id = #{@product.id}) AND events.received AND events.received_date <= '#{@end_date}'::date ORDER BY events.received_date")
			inv=d.map { |a| a["count"].to_i }.reverse
			box=d.map { |a| a["box"]=="t" }.reverse
			price = d.map { |a| a["price"].to_f }.reverse
			event_id = d.map { |a| a["id"].to_i }.reverse
			inv.each_with_index do |c,i| 
				if box[i]
					inv[i] = Product.find(1).per_box * c
				end
				price[i] = price[i]/inv[i] + Event.find(event_id[i]).per_unit_cost
			end
			i=0
			total = purchases
			value = 0;
			while total > 0
				if total >= inv[i]
					total = total-inv[i]
					value = value + inv[i]*price[i]
				elsif total < inv[i]
					value = value + total*price[i]
					total = 0
				end
			end
			@value=value
			@orders=purchases
			@avg = @value/@orders
		else
			@value = rand*1000
			@orders = rand*1000
			@avg = @value/@orders
		end
		respond_to do |format|
      format.js
    end
	end
	
	def create_csv
		csv = CSV.generate(col_sep: "\t") do |csv|
			csv << ["name", "quantity per box", "60 day need", "90 day need", "120 day need"]
			Product.all.sort_by(&:id).each do |product|
				csv << [product.name, product.per_box, product.need(60).round, product.need(90).round, product.need(120).round]
			end
		end
		file ="inventory.csv"
		File.open(file, "w"){ |f| f << csv }
		send_file( file, type: 'text/csv')
	end
	
	def edit
		@title = "Edit Product"
		@product = Product.find(params[:id])
	end

	def autocomplete
		@products = Product.search(params[:term])
		render json: @products.map(&:name)
	end
	
	def update
		@product = Product.find(params[:id])
		@product.update_attributes(params[:product])
		redirect_to @product
	end
	
	def all_cogs
		@title ="Cost of Goods Sold"
		if params[:start_date]
  		@start_date = Date.new(params[:start_date][:year].to_i,params[:start_date][:month].to_i,params[:start_date][:day].to_i)
  		@end_date = Date.new(params[:end_date][:year].to_i,params[:end_date][:month].to_i,params[:end_date][:day].to_i)
  	else
  		@start_date = Date.today.beginning_of_year
  		@end_date = Date.today.end_of_year
  	end
  	sql = ActiveRecord::Base.connection()
  	@product={}
		@value={}
		@orders={}
		@avg={}
		@value_total=0
		@orders_total=0
  	Product.all.each_with_index do |product,i|
			if Rails.env.production?
				d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity) as purchases FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (products.id = #{product.id}) AND orders.date <= '#{@end_date}'::date AND orders.date >= '#{@start_date}'::date")
				purchases=d[0]["purchases"].to_i
				d=sql.execute("SELECT product_counts.count as count, product_counts.is_box as box, events.id as id, product_counts.price as price from product_counts INNER JOIN events ON events.id = product_counts.event_id WHERE (product_counts.product_id = #{product.id}) AND events.received AND events.received_date <= '#{@end_date}'::date ORDER BY events.received_date")
				if d.count >0
				inv=d.map { |a| a["count"].to_i }.reverse
				box=d.map { |a| a["box"]=="t" }.reverse
				price = d.map { |a| a["price"].to_f }.reverse
				event_id = d.map { |a| a["id"].to_i }.reverse
				else
					inv=0
					box=0
					price = 0
					event_id = 0
				end
				inv.each_with_index do |c,i| 
					if box[i]
						inv[i] = Product.find(1).per_box * c
					end
					price[i] = price[i]/inv[i] + Event.find(event_id[i]).per_unit_cost
				end
				i=0
				total = purchases
				value = 0;
				while total > 0
					if total >= inv[i]
						total = total-inv[i]
						value = value + inv[i]*price[i]
					elsif total < inv[i]
						value = value + total*price[i]
						total = 0
					end
				end
				@product[i]=product
				@value[i]=value
				@orders[i]=purchases
			else
				@product[i] = product
				@value[i] = rand*1000
				@orders[i] = rand*1000
			end
			@value_total=@value[i]+@value_total
			@orders_total=@orders[i]+@orders_total
		end
	end
	
	def show
    @product = Product.find(params[:id])
    @title = @product.name
    if params[:start_date]
  		@start_date = Date.new(params[:start_date][:year].to_i,params[:start_date][:month].to_i,params[:start_date][:day].to_i)
  		@end_date = Date.new(params[:end_date][:year].to_i,params[:end_date][:month].to_i,params[:end_date][:day].to_i)
  	else
  		@start_date = Date.today.beginning_of_year
  		@end_date = Date.today.end_of_year
  	end
  	if Rails.env.production?
			sql = ActiveRecord::Base.connection()
			d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity) as purchases FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (products.id = #{@product.id}) AND orders.date <= '#{@end_date}'::date AND orders.date >= '#{@start_date}'::date")
			purchases=d[0]["purchases"].to_i
			d=sql.execute("SELECT product_counts.count as count, product_counts.is_box as box, events.id as id, product_counts.price as price from product_counts INNER JOIN events ON events.id = product_counts.event_id WHERE (product_counts.product_id = #{@product.id}) AND events.received AND events.received_date <= '#{@end_date}'::date ORDER BY events.received_date")
			inv=d.map { |a| a["count"].to_i }.reverse
			box=d.map { |a| a["box"]=="t" }.reverse
			price = d.map { |a| a["price"].to_f }.reverse
			event_id = d.map { |a| a["id"].to_i }.reverse
			inv.each_with_index do |c,i| 
				if box[i]
					inv[i] = Product.find(1).per_box * c
				end
				price[i] = price[i]/inv[i] + Event.find(event_id[i]).per_unit_cost
			end
			i=0
			total = purchases
			value = 0;
			while total > 0
				if total >= inv[i]
					total = total-inv[i]
					value = value + inv[i]*price[i]
				elsif total < inv[i]
					value = value + total*price[i]
					total = 0
				end
			end
			@value=value
			@orders=purchases
			@avg = @value/@orders
		else
			@value = rand*1000
			@orders = rand*1000
			@avg = @value/@orders
		end
  end
	
	def index
		@title = "All Products"
    @products = Product.all.sort_by { |a| a.id }.paginate(:page => params[:page], :per_page => 10)
	end
	
	def destroy
    Product.find(params[:id]).destroy
    redirect_to products_path 
  end
end
