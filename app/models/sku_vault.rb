class SkuVault
	include HTTParty
	
	headers 'Accept' => 'application/json'
	
	def initialize()
		@options = { query: {"pageNumber" => 1, "tenantToken" => ENV["tenant_token"], "userToken" => ENV["user_token"]} }
	end

	def get_item_quantities
		self.class.post("https://app.skuvault.com/api/inventory/getItemQuantities", @options).parsed_response["Items"]
	end

	def get_kit_quantities
		self.class.post("https://app.skuvault.com/api/inventory/getKitQuantities", @options)
	end
	
	def get_warehouse_item_quantities
		self.class.post("https://app.skuvault.com/api/inventory/GetWarehouseItemQuantities", @options)
	end
	
	def get_warehouse_item_quantity(options = {})
	  options = {warehouse_id: 225, sku:"A1", page_number: 1}.merge(options)
		@options[:query]["WarehouseId"]=options[:warehouse_id]
		@options[:query]["Sku"]= options[:sku]
		@options[:query]["pageNumber"]= options[:page_number]
		self.class.post("https://app.skuvault.com/api/inventory/GetWarehouseItemQuantity", @options).parsed_response["TotalQuantityOnHand"]
	end


end
