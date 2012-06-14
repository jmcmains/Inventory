Inventory::Application.routes.draw do
	root to: 'events#new_inventory'
	resources :products
	resources :product_counts
	resources :events do
		collection do
			get :inventory
			get :po
			get :new_inventory
			get :new_po
		end
	end
	resources :orders do
		collection do
			get :new_phone
		end
	end
	resources :offerings
end
