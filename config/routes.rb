Rails.application.routes.draw do
    #add root par defaut for api
    root to: "static#home"
    #Mount action cable for real time (chat Or Notification)
    mount ActionCable.server => "/cable"

    #EndPoints
      #Authentification System End Points
      resources :sessions, only: [:create]
      delete :logout, to: "sessions#logout"
      get :logged_in, to: "sessions#logged_in"

      #add registration (register page ) + confirmation de l'email
      resources :registrations, only: [:create] do
        member do
          get :confirm_email
        end
      end

      namespace :api do
        namespace :v1 do
          get 'statistique', to: 'users#count_all_for_admin'
          resources :doctors
        end
      end
    # resources :messages
    # get 'nearest_doctors', to: 'doctors#nearest'
    # resources :users
end
