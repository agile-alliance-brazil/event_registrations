#!/usr/bin/env ruby

if ARGV.count < 2
  puts <<-END
Usage: #{File.basename(__FILE__)} <user> <target_machine> <optional_ssh_key>

<user>: The user that will be used to ssh into the machine. Either root for Digital Ocean machines or ubuntu for AWS EC2 machines. It MUST have an ssh key already set up to ssh into.
<target_machine>: The public DNS or public IP address of the machine to be deployed
<optional_ssh_key>: The path to the ssh key to be used to log in with the specified user on the specified machine
END
  exit(1)
end

@user = ARGV[0]
@target = ARGV[1]
@key_path = ARGV[2] if ARGV.size > 2
RAILS_ROOT = File.join(File.dirname(__FILE__), '..')
REMOTE_SHARED_FOLDER = '/srv/apps/registrations/shared'

def files_to_upload
  [
    'config/config.yml',
    'config/database.yml',
    'certs/paypal_cert.pem',
    'certs/app_cert.pem',
    'certs/app_key.pem'
  ]
end

def tag_with_target(file)
  File.expand_path File.join(RAILS_ROOT, file.reverse.sub('/', "/#{@target}_".reverse).reverse)
end

def origin_files
  files_to_upload.map { |file| tag_with_target(file) }
end

def missing_files
  origin_files.reject { |file| File.exist?(file) }
end

if missing_files.size > 0
  puts "Cannot deploy until the following files are available."
  puts ""
  missing_files.each do |file|
    puts "#{file}"
  end
  exit(1)
end

def execute(command)
  puts "Running: #{command}"
  puts `#{command}`
end

def key_param
  @key_path.nil? ? '' : "-i #{@key_path}"
end

execute "scp #{key_param} #{RAILS_ROOT}/puppet/script/kickstart-server.sh #{@user}@#{@target}:~"
execute "ssh #{key_param} #{@user}@#{@target} '/bin/chmod +x ~/kickstart-server.sh && /bin/bash ~/kickstart-server.sh'"
unless File.exist?("config/deploy/#{@target}.rb")
  deploy_configs = File.read(File.join(RAILS_ROOT, 'config/deploy/staging.rb'))
  File.open("config/deploy/#{@target}.rb", 'w+') do |file|
    file.write deploy_configs.gsub(/set :domain,\s*"[^"]*"/, "set :domain, \"#{@target}\"")
  end
end
@deployed_user = File.read("config/deploy/#{@target}.rb").match(/user[^']+'([^']+)'/)[1]
execute "bundle"
execute "bundle exec cap #{@target} deploy:check:directories deploy:check:make_linked_dirs"
files_to_upload.each do |file|
  execute "scp #{key_param} #{tag_with_target(file)} #{@deployed_user}@#{@target}:#{REMOTE_SHARED_FOLDER}/#{file}"
end
execute "bundle exec cap #{@target} deploy"
