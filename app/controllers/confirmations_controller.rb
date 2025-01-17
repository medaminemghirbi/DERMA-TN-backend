class ConfirmationsController < Devise::ConfirmationsController
    def show
        super do |resource|
            if resource.errors.empty?
            redirect_to 'http://localhost:4200/login' and return
            end
        end
    end
end