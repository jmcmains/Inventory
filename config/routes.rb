Inventory::Application.routes.draw do
	root to: 'static_pages#home'
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
			get :create_phone
		end

	end
	resources :offerings
end
