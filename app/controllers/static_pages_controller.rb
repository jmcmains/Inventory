class StaticPagesController < ApplicationController
  def home
    start_day = Date.today - 1.month
    end_day = Date.today - 1.day
    sql = ActiveRecord::Base.connection()
    d=sql.execute("SELECT orders.count as count, orders.date as dates from orders WHERE orders.date >= '#{start_day}'::date AND orders.date <= '#{end_day}'::date GROUP BY orders.date ORDER BY orders.date")
    cnt=d.map { |a| a["count"].to_i }
    dates=d.map { |a| Date.parse(a["dates"]) }
    dates2=(start_day..end_day).to_a
    cnt2=Array.new(dates2.length,0) 
    dates.each_with_index do |d,i|
      cnt2[dates2.index(d)]=cnt[i]
    end
    @no_orders=cnt2.sum{ |a| a < 1 ? 1 : 0 }
    @empty_offering= Offering.includes(:products).where("products.id IS NULL").references(:products).count
    @late_pos=Event.unreceived.where("expected_date < ?",Date.today).count
 		@title ="RubberBanditz Inventory Launching Page"
 		@subtitle= "What would you like to do?"
  end
  
  def paypal
  	redirect_to "https://www.paypal.com/us/vst/id=#{params[:Order_ID]}"
  end
  
  def landing_page
    render layout: false
  end
end


