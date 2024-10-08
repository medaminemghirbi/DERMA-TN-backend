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
          resources :doctors do
            post 'activate_compte', on: :member
          end
          resources :patients
          resources :consultations
          resources :blogs
          resources :maladies
          resources :holidays
          resources :messages
          resources :notifications, only: [:create, :index]
          resources :phone_numbers
          resources :documents

          resources :users do
            member do
              put 'email_notifications', to: 'users#update_email_notifications'
              put 'system_notifications', to: 'users#update_system_notifications'
            end
          end  
          get 'messages/:message_id/images/:image_id', to: 'messages#download_image'
          delete 'destroy_all', to: 'messages#destroy_all'


          get 'reload_data', to: 'scrapers#run'
          get 'last_run', to: 'scrapers#last_run'

          post 'predict/:doctor_id', to: 'predictions#predict'

    
          get 'doctor_consultations_today/:doctor_id', to: 'consultations#doctor_consultations_today'
          get 'doctor_appointments/:doctor_id', to: 'consultations#doctor_appointments'
          get 'consultations/available_seances/:doctor_id', to: 'consultations#available_seances_for_year'
          get 'doctor_consultations/:doctor_id', to: 'consultations#doctor_consultations'
          get 'available_time_slots/:date/:doctor_id', to: 'consultations#available_time_slots'

          get 'verified_blogs', to: 'blogs#verified_blogs'
          get 'my_blogs/:doctor_id', to: 'blogs#my_blogs'


          get 'statistique', to: 'users#count_all_for_admin'
          patch 'update_location/:id', to: 'users#update_location'

          get 'all_locations', to: 'doctors#unique_locations'
          get 'doctor_stats/:doctor_id', to: 'doctors#getDoctorStatistique'
          patch 'doctors/:id/upgrade_plan', to: 'doctors#upgrade_doctor_plan'
          get 'get_doctors_by_locations/:location', to: 'doctors#get_doctors_by_locations'
          get 'location_details', to: 'locations#details'
          patch 'updatedoctorimage/:id', to: 'doctors#updatedoctorimage'
          patch 'updatedoctor/:id', to: 'doctors#updatedoctor'
          patch 'updatepassword/:id', to: 'doctors#updatepassword'
          patch 'update_uesr_informations/:id', to: 'users#update_uesr_informations'
          get 'download_file/:id', to: 'documents#download'
          delete 'delete_all_documents/:id', to: 'documents#delete_all_documents'

          
          
        end
      end

    # get 'nearest_doctors', to: 'doctors#nearest'
    # resources :users
end
