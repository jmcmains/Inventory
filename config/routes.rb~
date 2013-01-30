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
			get :new_order
		end
	end
	root to: 'static_pages#home'
	match '/paypal', to: 'static_pages#paypal'
	resources :products do
	collection do
			get :autocomplete
			get :monthly
		end
	end
	resources :product_counts
	resources :events do
		collection do
			get :inventory
			get :po
			get :po_received
			get :new_inventory
			get :new_po
		end
		member do
			get :receive_po_today
		end
	end
	resources :orders do
		collection do
			get :new_phone
			get :create_phone
			post :create_single
			get :combo
		end
	end
	resources :offerings do
	collection do
			get :blank
			get :autocomplete
			get :autocomplete_no_price
		end
	end
end
