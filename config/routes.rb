Inventory::Application.routes.draw do
	root to: 'StaticPages#home'
	resources :products
	resources :product_counts
	resources :events
	resources :orders
	resources :offerings
end
