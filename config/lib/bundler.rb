namespace :bundler do
	task :install, :roles => :app do 
		run "cd #{current_path} && bundle install"
	end
end