Rails.application.routes.draw do
  root 'actors#index'

  get 'actor/:id' => 'actors#show'
  get 'liked_actors' => 'actors#liked_actors'
  
  post 'actor/:id/update_like' => 'actors#update_like'
end
