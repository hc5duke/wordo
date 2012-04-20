Wordo::Application.routes.draw do
  root :to => 'home#index'
  match 'analyze' => 'home#analyze', :via => :post
end
