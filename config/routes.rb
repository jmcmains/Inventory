Inventory::Application.routes.draw do
  get "users/new"
	resources :users
	match '/signup', to: 'users#new'
	resources :customers do
		member do
			get :send_email
		end
	end
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
	resources :offerings do
	collection do
			get :blank
			get :autocomplete
			get :price
		end
	end
end
