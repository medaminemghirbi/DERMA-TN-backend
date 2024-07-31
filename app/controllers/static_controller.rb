class StaticController <ApplicationController
    def home
        render json: { status: "It's working" }
    end

    def static
        @employee = User.all.select { |m| m.role == 'employee' }.count
        @stagiaire = User.all.select { |m| m.role == 'stagiaire' }.count
        @freelancer = User.all.select { |m| m.role == 'freelancer' }.count
        @admin = User.all.select { |m| m.role == 'admin' }.count
        @offre = Offre.count

        render json: {
          data: [@employee, @stagiaire, @freelancer, @admin, @offre]
        }
      end

      def static_home
        @admins = User.all.select { |m| m.role == 'admin' }.count
        @candidates = User.all.select { |m| m.role != 'superadmin'&& m.role != 'admin'    }.count
        @domains = Domain.all.count
        @offers = Offre.all.count
        render json: {
            admin: @admins,
            offer: @offers,
            candidates: @candidates,
            domains: @domains
        }
      end

end