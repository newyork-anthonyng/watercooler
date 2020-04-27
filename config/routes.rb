Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :teams, only: [:create]
  post '/teams/invite', to: 'teams#invite'
  post '/teams/:id/applesauce', to: 'teams#applesauce'
  post '/verify/:invitation_hash', to: 'users#verify'
  post '/daily-check-in', to: 'daily_check_ins#check_in', as: 'daily_check_in'

  post 'login', to: 'sessions#create', as: 'login'
  post 'logout', to: 'sessions#destroy', as: 'logout'
end
