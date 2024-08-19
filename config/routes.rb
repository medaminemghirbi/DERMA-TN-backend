Rails.application.routes.draw do
    mount ActionCable.server => "/cable"
    resources :messages
    #add root par defaut for api
    root to: "static#home"

    #add sessions (login page )
    resources :sessions, only: [:create]
    get 'nearest_doctors', to: 'doctors#nearest'
    resources :users
    #add registration (register page ) + confirmation de l'email
    resources :registrations, only: [:create] do
      member do
        get :confirm_email
      end
    end

      #add sign out for front
    delete :logout, to: "sessions#logout"

      #add current logged_in user  for front
    get :logged_in, to: "sessions#logged_in"
end
