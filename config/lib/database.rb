namespace :symfony do
  namespace :database do
    namespace :migrations do
      desc "Executer les migrations sur les dernières versions disponible"
      task :migrate, :roles => :app, :except => { :no_release => true } do
        currentVersion = nil
        run "cd #{current_path} && php app/console --no-ansi doctrine:migrations:status", :once => true do |ch, stream, out|
          if stream == :out and out =~ /Current Version:.+\(([\w]+)\)/
            currentVersion = Regexp.last_match(1)
          end
          if stream == :out and out =~ /Current Version:\s*0\s*$/
            currentVersion = 0
          end
        end

        if currentVersion == nil
          raise "Impossible de trouver la version de la dernière migration effectuée"
        end
        puts "    Version actuelle: #{currentVersion}"

        forced = fetch(:always_agree)

        on_rollback {
        	if forced
        		agree = true
        	else
        		agree = Capistrano::CLI.ui.agree("Voulez_vous réelement revenir à la version #{currentVersion} de la BDD? (y/N)")
        	end

          if !interactive_mode || agree
            run "cd #{current_path} && php app/console doctrine:migrations:migrate #{currentVersion} --no-interaction", :once => true
          end
        }

        if forced
      		agree = true
      	else
      		agree = Capistrano::CLI.ui.agree("Voulez-vous réellement mettre à jour les schéma de la BDD au dernier fichier de migration disponible? (y/N)")
      	end

        if agree
          run "cd #{current_path} && php app/console doctrine:migrations:migrate --no-interaction", :once => true
        end
      end

      desc "Views the status of a set of migrations"
      task :status, :roles => :app, :except => { :no_release => true } do
        run "cd #{current_path} && php app/console doctrine:migrations:status", :once => true
      end
    end

  end
end