Inventory::Application.routes.draw do
  get "users/new"
	resources :users
	resources :sessions, only: [:new, :create, :destroy]
	
	match '/signup', to: 'users#new'
	match '/signin', to: 'sessions#new'
	match '/signout', to: 'sessions#destroy', via: :delete
	
	resources :customers do
		member do
			get :send_email
			get :send_oe_email
			get :send_customer_email
		end
	end
	root to: 'static_pages#home'
	resources :products do
	collection do
			get :autocomplete
		end
	end
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
		end
	end
end
