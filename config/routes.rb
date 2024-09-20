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
      post 'predict/:doctor_id', to: 'predictions#predict'

      namespace :api do
        namespace :v1 do
          get 'consultations/available_seances', to: 'consultations#available_seances'
          get 'statistique', to: 'users#count_all_for_admin'
          get 'all_locations', to: 'doctors#unique_locations'

          get 'get_doctors_by_locations/:location', to: 'doctors#get_doctors_by_locations'
          get 'doctor_consultations/:doctor_id', to: 'consultations#doctor_consultations'
          resources :doctors do
            post 'activate_compte', on: :member
          end
          resources :patients
          resources :consultations
          resources :blogs
          resources :maladies

          resources :messages
          get 'messages/:message_id/images/:image_id', to: 'messages#download_image'
          resources :holidays
          get 'reload_data', to: 'scrapers#run'
          get 'last_run', to: 'scrapers#last_run'
          delete 'destroy_all', to: 'messages#destroy_all'
          get 'doctor_consultations_today/:doctor_id', to: 'consultations#doctor_consultations_today'
          patch 'doctors/:id/upgrade_plan', to: 'doctors#upgrade_doctor_plan'

        end
      end

    # get 'nearest_doctors', to: 'doctors#nearest'
    # resources :users
end
