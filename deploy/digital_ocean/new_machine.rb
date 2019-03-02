#!/usr/bin/env ruby

require 'json'
require 'net/https'
require 'uri'
require 'English'
require 'dotenv'
require 'erb'
require 'ostruct'

APP_NAME='inscricoes'

Dotenv.load
unless ENV['TOKEN']
  puts "Ensure you've set the Digital ocean token using \"export TOKEN='your_token'\" or added it to your .env file"
  exit 1
end

TOKEN = ENV['TOKEN']
TYPE = ARGV.size > 0 ? (ARGV[0] == 'production' ? :production : :staging) : :staging
staging = TYPE != :production
POSTFIX = staging ? '-staging' : ''
ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../../'))
KEY_PATH = "#{ROOT}/certs/digital_ocean#{POSTFIX.tr('-', '_')}"

unless File.exists?(KEY_PATH)
  puts "Missing SSH private key at #{KEY_PATH}"
  puts "The corresponding SSH public key fingerprint should be registered in DigitalOcean's SSH key"
  puts "You can check it https://cloud.digitalocean.com/account/security"
  exit 1
end

unless File.exists?("#{KEY_PATH}.pub")
  `ssh-keygen -y -f #{KEY_PATH} > #{KEY_PATH}.pub`
end

`awk '{print $2}' #{KEY_PATH}.pub | base64 -D | md5 | sed 's/../&:/g; s/:$//'`
SSH = staging ? '36:18:0e:5c:aa:0c:58:9e:d2:72:5b:f7:f8:e7:f2:5d' : 'ba:49:c2:40:4e:18:dd:cb:bb:cd:9c:f6:99:11:67:db'

MANDATORY_FILES = [
  "#{ROOT}/config/#{TYPE}_config.yml",
  "#{ROOT}/config/#{TYPE}_database.yml",
  "#{ROOT}/certs/#{TYPE}_paypal_cert.pem",
  "#{ROOT}/certs/#{TYPE}_app_cert.pem",
  "#{ROOT}/certs/#{TYPE}_app_key.pem",
  "#{ROOT}/certs/#{TYPE}_server.crt",
  "#{ROOT}/certs/#{TYPE}_server_key.pem",
  "#{ROOT}/certs/#{TYPE}_intermediate.crt"
]

error = false
MANDATORY_FILES.each do |f|
  unless File.exists?(f)
    original_name = f.gsub("#{ROOT}/",'').gsub("#{TYPE}_", '')
    `scp -i "#{KEY_PATH}" "ubuntu@inscricoes#{POSTFIX}.agilebrazil.com:/srv/apps/registrations/shared/#{original_name}" "#{f}"`

    unless File.exists?(f)
      error = true
      puts "Missing file: #{f}"
    end
  end
end
if error
  puts "Ensure files exist and try again"
  exit 1
end

def get_json(uri)
  uri = URI.parse(uri)

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri,
    initheader = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{TOKEN}"
    })
  http.request(request)
end

def post_json(uri, body)
  uri = URI.parse(uri)

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.request_uri,
    initheader = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{TOKEN}"
    })
  request.body = body
  http.request(request)
end

def link_files(ip, file_name)
  "rm -f #{ip}_#{file_name} && ln -s #{TYPE}_#{file_name} #{ip}_#{file_name}"
end

droplets = get_json('https://api.digitalocean.com/v2/droplets')
machine_id = (JSON.parse(droplets.body)['droplets'].count do |d|
  d['name'].match(/#{APP_NAME}-\d\d#{POSTFIX}\./)
end + 1)

bootstrap_info = File.read(File.join(ROOT, 'puppet/script/server_bootstrap.sh'))
body = {
  names: ["#{APP_NAME}-#{format('%02d', machine_id)}#{POSTFIX}.agilebrazil.com"],
  region: 'nyc3',
  size: '1gb',
  image: 'ubuntu-18-04-x64',
  ssh_keys: [SSH],
  backups: false,
  ipv6: true,
  user_data: bootstrap_info,
  private_networking: nil
}

def generate_deploy_config(ip, template_path)
  destination = "#{ROOT}/config/deploy/#{ip}.rb"
  return if File.exist?(destination)

  template = ERB.new(File.read(template_path))
  namespace = OpenStruct.new(ip: ip)
  File.open(destination, 'w') do |f|
    f.puts template.result(namespace.instance_eval { binding })
  end
end

def setup_droplet(droplet)
  setup = "cd #{ROOT}/config && #{link_files(droplet[:ipv4], 'config.yml')} &&\
    #{link_files(droplet[:ipv4], 'database.yml')} &&\
    cd #{ROOT}/certs && #{link_files(droplet[:ipv4], 'paypal_cert.pem')} &&\
    #{link_files(droplet[:ipv4], 'app_cert.pem')} &&\
    #{link_files(droplet[:ipv4], 'app_key.pem')} &&\
    #{link_files(droplet[:ipv4], 'server.crt')} &&\
    #{link_files(droplet[:ipv4], 'server_key.pem')} &&\
    #{link_files(droplet[:ipv4], 'intermediate.crt')}"
  result = `#{setup}`
  return "ERROR: Cannot generate config files and certs for #{droplet[:ipv4]}.\n#{result}" unless $CHILD_STATUS.to_i == 0

  ssh_command = "ssh -i #{KEY_PATH} -o LogLevel=quiet -o StrictHostKeyChecking=no ubuntu@#{droplet[:ipv4]} 'echo \"SSH Successful!\"'"
  `#{ssh_command}` # Adding new machine to known hosts
  generate_deploy_config(droplet[:ipv4], "#{ROOT}/config/deploy/#{TYPE}.erb")
  first_deploy = "bundle exec ruby script/first_deploy.rb ubuntu #{droplet[:ipv4]} #{TYPE} #{KEY_PATH}"
  deploy_result = `#{first_deploy}`
  return "ERROR: Deploy failed on #{droplet[:ipv4]}\n#{deploy_result}" unless $CHILD_STATUS.to_i == 0

  url = "https://#{droplet[:ipv4]}"
  `curl -k "#{url}"`
  return "ERROR: Deploy successful on #{url} but HTTPS is not working.\n#{deploy_result}" unless $CHILD_STATUS.to_i == 0

  "SUCCESS: #{url} is up an running!"
end

response = post_json('https://api.digitalocean.com/v2/droplets', body.to_json)
if response.code.to_i < 400
  droplet_response = JSON.parse(response.body)
  ids = droplet_response['droplets'].map { |d| d['id'] }
  sleep(120 * (ids.size.to_f / 10).ceil) # wait for droplets to get network data & run the bootstrap
  droplet_infos = ids.map do |id|
    info = get_json("https://api.digitalocean.com/v2/droplets/#{id}")
    if info.code.to_i < 400
      JSON.parse(info.body)
    else
      info.body
    end
  end
  errors, successes = droplet_infos.partition { |i| i.is_a? String }
  if errors.size > 0
    puts 'ERRORS: The following are unknown droplets'
    puts errors
  end
  if successes.size > 0
    droplets = successes.map do |d|
      {
        id: d['droplet']['id'],
        ipv4: d['droplet']['networks']['v4'].map { |i| i['ip_address'] }.first,
        ipv6: d['droplet']['networks']['v6'].map { |i| i['ip_address'] }.first
      }
    end
    puts droplets.map { |d| setup_droplet(d) }.join("\n\n")
  end
else
  puts 'ERROR: Droplets failed'
  puts response.body
end
