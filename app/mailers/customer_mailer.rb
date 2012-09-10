class CustomerMailer < ActionMailer::Base
  default from: "info@rubberbanditz.com"
  default bcc: "jason@rubberbanditz.com"
  
  def oe_email(customer)
  	@customer = customer
  	mail(:to => "orders@rubberbanditz.com", :subject => "Customer Order - #{@customer.first_name} #{@customer.last_name}")
  end
  
  def customer_email(customer)
  	@customer = customer
  	mail(:to => "#{@customer.first_name} #{@customer.last_name} <#{@customer.email}>", :subject => "Thank you for your order with Rubberbanditz!")
  end
end
