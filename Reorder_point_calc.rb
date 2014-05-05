product=Product.first

averageLeadTime=product.received.to_a.sum { |a| a.received_date - a.date }.to_f / product.received.count
standardDeviationOfLeadTime=(product.received.to_a.sum { |a| ((a.received_date - a.date) - averageLeadTime)**2 }.to_f / product.received.count)**0.5

sql = ActiveRecord::Base.connection()
d=sql.execute("SELECT SUM(orders.quantity * offering_products.quantity), orders.date AS date FROM orders INNER JOIN offerings ON offerings.id = orders.offering_id INNER JOIN offering_products ON offering_products.offering_id = offerings.id INNER JOIN products ON products.id = offering_products.product_id WHERE (products.id = #{product.id}) GROUP BY date ORDER BY date ")

dates = d.map { |a| a["date"].to_date }
orders = d.map { |a| a["sum"].to_f }

dates2=((dates.count > 0 ? dates.first : Date.new(2010,1,1))..Date.today).to_a
orders2=Array.new(dates2.length,0)
dates.each_with_index do |d,i|
	orders2[dates2.index(d)]=orders[i]
end


total_orders=orders2.sum
averageDemand=total_orders/orders2.count
standardDeviationOfDemand=(orders2.map { |a| (a - averageDemand)**2 }.sum/orders2.count)**0.5

serviceLevel=0.99
reorderPoint = averageLeadTime*averageDemand + serviceLevel*(averageLeadTime*standardDeviationOfDemand**2 + averageDemand**2*standardDeviationOfLeadTime**2)**0.5

# Including orders in process

reorderPoint - product.get_orders(averageLeadTime)

