Rails.application.routes.draw do
  get 'surveys/index'

  get 'home/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :surveys

  #home pages
  match '/about/' => 'home#about', :via => :get
  match '/help/' => 'home#help', :via => :get
  match '/examples/' => 'home#examples', :via => :get
  match '/legal/' => 'home#legal', :via => :get

  match '/:id' => 'surveys#take', :via => :get, :as => :take
  match '/:id' => 'surveys#respond', :via => :post
  match '/results/:id' => 'surveys#results', via: [:get, :post], :as => :results
  match '/admin/:id/close' => 'surveys#toggle', via: [:get, :post], :as => :closesurvey, :state => true
  match '/admin/:id/unclose' => 'surveys#toggle', via: [:get, :post], :as => :unclosesurvey, :state => false

  root :to => "home#index", :via => :get
end
