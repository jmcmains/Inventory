Inventory::Application.routes.draw do
	root to: 'StaticPages#home'
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
	resources :orders
	resources :offerings
end
