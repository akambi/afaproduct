namespace :status do 
	task :check, :roles => :app do 
		#TODO réaliser qqes test fonctionnels
	end

	task :after_setup, :roles => :app do
		update_status('setup')
	end
	after 'deploy:setup', 'status:after_setup'

	task :after_deploy, :roles => :app do
		update_status('deploy')
	end
	after 'deploy', 'status:after_deploy'

	task :phpunit, :roles => :app do
		pretty_print "--> Execution des test PHPUnit"
		stream "cd #{current_path} && phpunit -c app/"
	end
end