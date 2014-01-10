namespace :symfony do
  desc "Lancer des commandes spécifiques"
  task :default, :roles => :app, :except => { :no_release => true } do |args|
    prompt(:task_arguments, "cache:clear")
    stream "cd #{current_path} && php app/console #{task_arguments}"
  end

  namespace :logs do
    [:tail, :tail_dev, :tail_test].each do |action|
      lines = ENV['lines'].nil? ? '50' : ENV['lines']
      if action.to_s == 'tail'
        log = 'prod.log'
      elsif action.to_s == 'tail_test'
        log = 'test.log'
      else
        log = 'dev.log'
      end
      desc "Deboggage (tail #{log})"
      task action, :roles => :app, :except => { :no_release => true } do
        run "tail -n #{lines} -f #{shared_path}/app/logs/#{log}" do |channel, stream, data|
          trap("INT") { puts 'Interrompu'; exit 0; }
          puts
          puts "#{channel[:host]}: #{data}"
          break if stream == :err
        end
      end
    end
  end

  namespace :assets do

    set :assets_symlinks, true
    set :assets_relative, false

    desc "Mettre à jour les assets (méthode dure)"
    task :update_version, :roles => :app, :except => { :no_release => true } do
       run "sed -i 's/\\(assets_version: \\)\\([a-zA-Z0-9_]*\\)\\(.*\\)$/\\1 \"#{real_revision[0,7]}\"\\3/g' #{current_path}/app/config/config.yml"
    end

    desc "Mettre à jour les assets (via le bundle)"
    task :install, :roles => :app, :except => { :no_release => true } do
      pretty_print "--> Installation des assets"

      install_options = ''

      if true == assets_symlinks then
          install_options += " --symlink"
      end

      if true == assets_relative then
          install_options += " --relative"
      end
      set :use_sudo, true
      run "cd #{current_path} && php app/console assets:install #{install_options}"
      set :use_sudo, false
      success
    end
  end

  namespace :assetic do
    desc "Générer les fichiers gérés par Assetic"
    task :dump, :roles => :app,  :except => { :no_release => true } do
      pretty_print "--> Génération des fichiers 'Assetic'"

      run "cd #{current_path} && php app/console assetic:dump --no-debug"
      success
    end
  end

  namespace :bootstrap do
    desc "Reconstruire le cache de démarrage"
    task :build, :roles => :app, :except => { :no_release => true } do
      pretty_print "--> Reconstruction du cache"

      set :build_bootstrap, "vendor/sensio/distribution-bundle/Sensio/Bundle/DistributionBundle/Resources/bin/build_bootstrap.php"

      if !remote_file_exists?("#{current_path}/#{build_bootstrap}")
        run "test -f #{current_path}/#{build_bootstrap} && php #{current_path}/#{build_bootstrap} #{current_path}/app || echo '#{build_bootstrap} not found, skipped'"
      else
        run "test -f #{current_path}/#{build_bootstrap} && php #{current_path}/#{build_bootstrap} #{current_path}/app || echo '#{current_path}/#{build_bootstrap} not found, skipped'"
      end

    end
  end

  namespace :composer do
    desc "Installer Composer"
    task :install, :roles => :app, :except => { :no_release => true } do
      pretty_print "--> Installation de Composer"
      #run "#{try_sudo} chown -R #{user}:www-data ."
      run "mkdir -p #{shared_path}/vendor"
      run "cd #{shared_path} && curl -s http://getcomposer.org/installer | php"
    end

    desc "Mettre à jour Composer"
    task :self_update, :roles => :app, :except => { :no_release => true } do
      pretty_print "--> MAJ de Composer"
      run "cd #{current_path} && php composer.phar self-update"
    end

    desc "Optimiser l'autoloader"
    task :optimize, :roles => :app, :except => { :no_release => true } do
      pretty_print "--> Optimisation de l'autoloader"
      run "cd #{current_path} && php composer.phar dump-autoload --optimize"
    end

    desc "Détection automatique de l'action a réaliser sur les vendors"
    task :vendors_auto, :roles => :app, :except => { :no_release => true } do
    	pretty_print "--> Détection de l'action à réaliser sur les vendors"
    	if 0 > capture("echo #{shared_path}/vendor | wc -w").to_i
        vendors_update
      else
      	vendors_install
      end
    end

    desc "Mettre à jour les vendors"
    task :vendors_update, :roles => :app, :except => { :no_release => true } do
      pretty_print "--> Update des vendors"
      symlink
      run "cd #{current_path} && php composer.phar update"
    end

    desc "Installer les vendors"
    task :vendors_install, :roles => :app, :except => { :no_release => true } do
      pretty_print "--> Install des vendors"
      symlink
      run "cd #{current_path} && php composer.phar install"
    end

    desc "Symlinker les vendors"
    task :symlink, :roles => :app, :except => { :no_release => true } do
    	pretty_print "--> Symlink des vendors"
    	run "ln -s #{shared_path}/vendor #{current_path}/vendor"
      run "ln -s #{shared_path}/composer.phar #{current_path}/composer.phar"
    end
  end

  namespace :cache do
    desc "Supprimer le cache"
    task :clear, :roles => :app, :except => { :no_release => true } do
      pretty_print "--> Suppression du cache"
      set :use_sudo, true
      run "cd #{current_path} && php app/console cache:clear --env=prod"
      run "#{try_sudo} chmod -R g+w #{current_path}/app/cache"
      set :use_sudo, false
    end

    desc "Warms du cache"
    task :warmup, :roles => :app, :except => { :no_release => true } do
      pretty_print "--> Warm du cache"
      set :use_sudo, true
      run "cd #{current_path} && php app/console cache:warmup"
      #run "sudo -p 'sudo password: ' chmod -R g+w #{current_path}/app/cache"
      set :use_sudo, false
    end
  end
end