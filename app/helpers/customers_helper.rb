module CustomersHelper
	def modaddy(addy)
		addy.gsub!(/[\n]+/, "<br>");
	end
end
