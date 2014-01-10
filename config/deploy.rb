# encoding: utf-8

# Configuration du nom de l'application (nom du dépôt)
set :application, "li-ihm.transilien"

# Configuration du root path ( ne pas modifier )
set (:root_path)    { File.expand_path File.dirname(__FILE__) }

# inclusion de la gem capistrano-ctp (bibliotheque interne)
require "capistrano/ctp"
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| load file }

load "ctp/templates"
load "ctp/custom_files"


# Configuration du dépot des source
set :scm,               :git
set :scm_username,      "phpteam"
set :scm_passphrase,    "Canaltp21"
set :repository,        "http://hg.prod.canaltp.fr/LieuIdealProduct.git"

# Branche à deployer
_cset (:branch)         {"release"}

# liste des dossiers à exclure de deploiement
set :copy_exclude,      ['Capfile', 'Gemfile', '.hg*', '/tests/', 'vendor']

# definition de l'adresse mail d'admin (utilisé dans le virtual host)
set :admin_email,       "admin@canalp.fr"

#definition du ServerName, si ce n'est pas déjà effectué.
set (:servername)       {"#{application.downcase}.#{stage.to_s}.canaltp.fr"}

set :use_sudo, false

set :always_agree, true


namespace :app do
    namespace :db do
      desc "Migrate DB with schema"
        task :prepare, :roles => :db do
          #symfony.database.migrations.migrate
          if first_deploy?
            pretty_print "--> Ajout des fonctions PL/pgSQL'"
            template 'pgpass.erb', '.pgpass'
            template 'pgfunc.erb', '.pg_functions'

            run "chmod 0600 .pgpass"
            run "psql -f .pg_functions -h localhost -d #{db_database} -U #{db_username}"
            run "rm ~/.pgpass && rm ~/.pg_functions"

           app.db.seed
          end
        end
        #after 'deploy:symlink', 'app:db:prepare'

        task :seed, :roles => :app  do
          pretty_print "--> Seed de la base de données'"
          count = 0
          find_servers_for_task(current_task).each do |server|
            run( "cd #{current_path} && php app/console lieuideal:update:stoparea", :hosts => server.host) unless count > 0
            run( "cd #{current_path} && php app/console lieuideal:update:correspondence", :hosts => server.host) unless count > 0
            ++count
          end
        end
    end


    task :whoami, :roles => :web do
      pretty_print "--> Étiquetage des serveurs avec leur URL publiques individuelles"
      usn = fetch :unique_servername
      find_servers_for_task(current_task).each do |server|
        run( "cd #{shared_path}/app && echo '" + usn[server.host] + "' > ./.whoami_response", :hosts => server.host)
      end
    end

    namespace :cron do
        desc "Mise en place des cron"
        task :install, :roles => :db, :only => {:primary => true} do
            bundle.install
            run "cd #{current_path} && whenever --update-crontab"
        end
       #after 'deploy', 'app:cron:install'
    end
end


