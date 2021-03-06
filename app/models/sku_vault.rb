class SkuVault
	include HTTParty
	
	headers 'Accept' => 'application/json'
	
	def initialize()
		@options = { query: {"pageNumber" => 0, "tenantToken" => ENV["tenant_token"], "userToken" => ENV["user_token"], "WarehouseId" => ENV["warehouse_id"]} }
	end

	def get_item_quantities
		self.class.post("https://app.skuvault.com/api/inventory/getItemQuantities", @options).parsed_response["Items"]
	end

	def get_kit_quantities
		self.class.post("https://app.skuvault.com/api/inventory/getKitQuantities", @options).parsed_response["Kits"]
	end
	
	def get_warehouse_item_quantities
		self.class.post("https://app.skuvault.com/api/inventory/GetWarehouseItemQuantities", @options).parsed_response["ItemQuantities"]
	end
	
	def get_warehouse_item_quantity(sku)
		@options[:query]["Sku"]= sku
		self.class.post("https://app.skuvault.com/api/inventory/GetWarehouseItemQuantity", @options).parsed_response["TotalQuantityOnHand"]
	end


end
