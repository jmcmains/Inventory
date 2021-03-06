class Customer < ActiveRecord::Base
  require 'active_shipping'
	include ActiveMerchant::Shipping
  has_many :orders, dependent: :destroy
  accepts_nested_attributes_for :orders
  
  def self.search(search)
  	if search
			words = search.to_s.strip.split
		  words.inject(scoped) do |combined_scope, word|
		    combined_scope.where('LOWER(first_name) LIKE ? OR LOWER(last_name) LIKE ? OR LOWER(transaction_number) LIKE ? OR LOWER(email) LIKE ?',"%#{word.downcase}%","%#{word.downcase}%","%#{word.downcase}%","%#{word.downcase}%")
		  end
  	else
  		return find(:all)
  	end
  end
  
  def shipping_cost
		weight=0
		orders.each do |o|
				weight += o.offering.total_weight*o.quantity
		end
		package=Package.new(  (weight * 16),[],:units => :imperial)
		origin = Location.new(:country => 'US',:state => 'NC',:city => 'Hillsborough',:zip => '27278')
		destination = address
    usps = USPS.new(:login => ENV['usps_login'])
		response = usps.find_rates(origin, destination, package)
		usps_rates = response.rates.sort_by(&:price).collect {|rate| [rate.service_name, rate.price]}
		return usps_rates
  end
end
