def guess_symfony_version
  capture("cd #{latest_release} && #{php_bin} #{symfony_console} --version |cut -d \" \" -f 3")
end

def remote_file_exists?(full_path)
  'true' == capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

def remote_command_exists?(command)
  'true' == capture("if [ -x \"$(which #{command})\" ]; then echo 'true'; fi").strip
end



namespace :deploy do
  desc "Migrate DB with schema"
  task :migrate, :roles => :app do
    symfony.database.migrations.migrate
  end

  desc <<-DESC
    Sets permissions for writable_dirs folders as described in the Symfony documentation
    (http://symfony.com/doc/master/book/installation.html#configuration-and-setup)
  DESC
  task :set_permissions, :roles => :app, :except => { :no_release => true } do
    set :writable_dirs, ['app/logs', 'app/cache', 'web']
    set :permission_method, :chown
    set :use_sudo, true

    if writable_dirs && permission_method
      dirs = []

      writable_dirs.each do |link|
        if shared_children && shared_children.include?(link)
          absolute_link = shared_path + "/" + link
        else
          absolute_link = latest_release + "/" + link
        end

        dirs << absolute_link
      end

      methods = {
        :chmod => [
          "chmod +a \"#{user} allow delete,write,append,file_inherit,directory_inherit\" %s",
          "chmod +a \"www-data allow delete,write,append,file_inherit,directory_inherit\" %s"
        ],
        :acl   => [
          "setfacl -R -m u:#{user}:rwx -m u:www-data:rwx %s",
          "setfacl -dR -m u:#{user}:rwx -m u:www-data:rwx %s"
        ],
        :chown => ["chown -R #{user}:www-data %s"]
      }

      if methods[permission_method]
        pretty_print "--> Setting permissions"

        if fetch(:use_sudo, false)
          methods[permission_method].each do |cmd|
            #sudo sprintf(cmd, dirs.join(' '))
          end
        elsif permission_method == :chown
          puts "    You can't use chown method without sudoing"
        else
          dirs.each do |dir|
            is_owner = (capture "`echo stat #{dir} -c %U`").chomp == user
            if is_owner && permission_method != :chown
              methods[permission_method].each do |cmd|
                try_sudo sprintf(cmd, dir)
              end
            else
              puts "    #{dir} is not owned by #{user} or you are using 'chown' method without ':use_sudo'"
            end
          end
        end
        success
      else
        puts "    Permission method '#{permission_method}' does not exist.".yellow
      end
    end
    set :use_sudo, false
  end

  desc "Symlinks static directories and static files that need to remain between deployments"
  task :share_childs, :roles => :app, :except => { :no_release => true } do

    set :shared_children, ["app/logs", "web/uploads", "web/tmp"]
    set :shared_files,    []

    if shared_children
      pretty_print "--> Creation des dossiers partagés"

      shared_children.each do |link|
        run "mkdir -p #{shared_path}/#{link}"
        run "sh -c 'if [ -d #{current_path}/#{link} ] ; then rm -rf #{current_path}/#{link}; fi'"
        run "ln -nfs #{shared_path}/#{link} #{current_path}/#{link}"
      end

      success
    end

    if shared_files
      pretty_print "--> Creation des fichiers partagés"

      shared_files.each do |link|
        link_dir = File.dirname("#{shared_path}/#{link}")
        run "mkdir -p #{link_dir}"
        run "touch #{shared_path}/#{link}"
        run "ln -nfs #{shared_path}/#{link} #{current_path}/#{link}"
      end

      success
    end
  end

  desc "Finalisation de l'update"
  task :finalize, :roles => :app, :except => { :no_release => true } do
    set :use_sudo, true

    run "#{try_sudo} chmod -R 775 #{latest_release}" if fetch(:group_writable, true)

    pretty_print "--> Création du cache"

    #run "#{try_sudo} sh -c 'if [ -d #{late/var/www/websites/prod/lieuideal/shared/st_release}/app ] ; then rm -rf #{latest_release}/app; fi'"
    #"run "#{try_sudo} sh -c 'mkdir -p #{latest_release}/app && chmod -R 0777 #{latest_release}/app'"


    success
    set :use_sudo, false

    share_childs
  end

  desc "Effectuer un Setup puis un deploy"
  task :cold, :roles => :app, :except => { :no_release => true } do
    deploy.setup
    deploy.deploy
  end

  desc "Deployer l'application est s'assurer du bon fonctionnement du site avec des tests unitaires"
  task :valid, :roles => :app, :except => { :no_release => true } do
    update_code
    create_symlink
    run "cd #{current_path} && phpunit -c #{current_path}/app src'"
  end

  desc "Symfony2 migrations"
  task :migrate, :roles => :app, :except => { :no_release => true }, :only => { :primary => true } do
    symfony.database.migrations.migrate
  end

  desc "Supprimer le site"
  task :drop do
    if Capistrano::CLI.ui.ask("Are you sure remove #{deploy_to} (y/n)") == 'y'
      run "#{try_sudo} rm -rf #{deploy_to}"
    end
  end
end

after "deploy:setup", "symfony:composer:install"
after "deploy",       "symfony:composer:vendors_auto"

after "symfony:composer:vendors_auto" do
  symfony.composer.optimize
  symfony.bootstrap.build

  symfony.assets.install
  symfony.assets.update_version

  symfony.cache.warmup
  symfony.assetic.dump

  deploy.set_permissions
  #status.phpunit
end

before "deploy:update_code" do
  msg = "--> Updating code base with #{deploy_via} strategy"

  status.check

  if logger.level == Logger::IMPORTANT
    errors
    puts msg
  else
    puts msg.green
  end
end


before "deploy:setup" do
	set :use_sudo, true
end

before "status:after_setup" do
	run "#{try_sudo} chown -R #{user}:www-data #{deploy_to}"
	set :use_sudo, false
end