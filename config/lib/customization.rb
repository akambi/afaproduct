require 'colored'
require 'json'
require 'yaml'

STDOUT.sync
$error = false
$pretty_errors_defined = false

# Be less verbose by default
# logger.level = Logger::IMPORTANT

def pretty_print(msg)
  if logger.level == Logger::IMPORTANT
    errors
    print '✔'+ msg.green + "\n\r"
  else
    puts '✔'+ msg.green
  end
end

def success
  if logger.level == Logger::IMPORTANT && !$error
    puts '✔'.green
  end

  $error = false
end

def errors
  if !$pretty_errors_defined
    $pretty_errors_defined = true

    class << $stderr
      @@firstLine = true
      alias _write write

      def write(s)
        if @@firstLine
          s = '✘' << "\n" << s
          @@firstLine = false
        end

        _write(s.red)
        $error = true
      end
    end
  end
end

# Gestion de l'état de l'application

def update_status(status)
  exists = remote_file_exists?("#{shared_path}/status.json")
	if !exists && status == 'setup'
    puts '-----------------------------------------------------------------------------------------'
    puts 'First Setup, initializing folders et files.'
    puts '-----------------------------------------------------------------------------------------'
		history = ['setup']
		put JSON.generate({:history => history, :inited => true}), "#{shared_path}/status.json"
	elsif !exists && status != 'setup'
		raise '--> ERREUR: L\'application n\'est pas initialisé. Merci de réaliser un deploy:setup avant de continuer'
	else
		get "#{shared_path}/status.json", '/tmp/status'
		json = JSON.parse(File.read('/tmp/status'))
		json['history'].push(status)
		put JSON.generate(json), "#{shared_path}/status.json"
	end
end

def first_deploy?
  exists = remote_file_exists?("#{shared_path}/status.json")
  if !exists
    false
  elsif exists
    get "#{shared_path}/status.json", '/tmp/status'
    json = JSON.parse(File.read('/tmp/status'))
    if "setup" == json['history'].last
      true
    else
      false
    end
  end
end

def prompt(var, default, &block)
  set(var) do
    Capistrano::CLI.ui.ask("#{var} [#{default}] : ", &block)
  end
  set var, default if eval("#{var.to_s}.empty?")
end

def template(from, to)
    source = File.read(File.expand_path("config/templates/#{from}"))
    put ERB.new(source).result(binding), to
end


def memcache_yaml
  if fetch(:memcache_hostname) && fetch(:memcache_port)
    memcache_params = {'memcached.servers' => [{'host' => fetch(:memcache_hostname), 'port' => fetch(:memcache_port)}]}
    #memcache_params.to_yaml.sub!(/^---/, '')
    puts memcache_params.to_yaml.sub!(/^---/, '')
    memcache_params.to_yaml.sub!(/^---/, '')
  else
    ''
  end
end