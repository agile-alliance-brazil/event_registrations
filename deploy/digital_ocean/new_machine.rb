#!/usr/bin/env ruby

require 'json'
require 'net/https'
require 'uri'
require 'English'

unless ENV['TOKEN']
  puts "Ensure you've set the Digital ocean token using \"export TOKEN='your_token'\""
  exit 1
end

TOKEN = ENV['TOKEN']
TYPE = :staging
staging = TYPE != :production
SSH = staging ? '36:18:0e:5c:aa:0c:58:9e:d2:72:5b:f7:f8:e7:f2:5d' : 'ba:49:c2:40:4e:18:dd:cb:bb:cd:9c:f6:99:11:67:db'
POSTFIX = staging ? '-staging' : ''
ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../../'))

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

droplets = get_json('https://api.digitalocean.com/v2/droplets')
machine_id = (JSON.parse(droplets.body)['droplets'].count do |d|
  d['name'].match(/inscricoes#{POSTFIX}/)
end + 1)

bootstrap_info = File.read(File.join(ROOT, 'puppet/script/server_bootstrap.sh'))
body = {
  names: ["inscricoes-#{format('%02d', machine_id)}#{POSTFIX}.agilebrazil.com"],
  region: 'nyc3',
  size: '1gb',
  image: 'ubuntu-14-04-x64',
  ssh_keys: [SSH],
  backups: false,
  ipv6: true,
  user_data: bootstrap_info,
  private_networking: nil
}

response = post_json('https://api.digitalocean.com/v2/droplets', body.to_json)
if response.code.to_i < 400
  puts 'Droplets created'
  puts response.body
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
    puts 'Unknown droplets:'
    puts errors
  end
  if successes.size > 0
    puts 'Successes:'
    droplets = successes.map do |d|
      {
        id: d['droplet']['id'],
        ipv4: d['droplet']['networks']['v4'].map { |i| i['ip_address'] }.first,
        ipv6: d['droplet']['networks']['v6'].map { |i| i['ip_address'] }.first
      }
    end
    droplets.each do |droplet|
      puts "Deploying to #{droplet[:id]} at #{droplet[:ipv4]}"
      setup = "cd #{ROOT}/config && rm -f #{droplet[:ipv4]}_config.yml &&\
        ln -s #{TYPE}_config.yml #{droplet[:ipv4]}_config.yml &&\
        rm -f #{droplet[:ipv4]}_database.yml &&\
        ln -s #{TYPE}_database.yml #{droplet[:ipv4]}_database.yml &&\
        cd #{ROOT}/certs && rm -f #{droplet[:ipv4]}_paypal_cert.pem &&\
        ln -s #{TYPE}_paypal_cert.pem #{droplet[:ipv4]}_paypal_cert.pem &&\
        rm -f #{droplet[:ipv4]}_app_cert.pem &&\
        ln -s #{TYPE}_app_cert.pem #{droplet[:ipv4]}_app_cert.pem &&\
        rm -f #{droplet[:ipv4]}_app_key.pem &&\
        ln -s #{TYPE}_app_key.pem #{droplet[:ipv4]}_app_key.pem"
      puts "Executing: #{setup}"
      result = `#{setup}`
      next unless $CHILD_STATUS.to_i == 0

      key_path = "#{ROOT}/certs/digital_ocean#{POSTFIX.tr('-', '_')}"
      ssh_command = "ssh -i #{key_path} -o StrictHostKeyChecking=no ubuntu@#{droplet[:ipv4]} 'echo \"SSH Successful!\"'"
      puts "Adding #{droplet[:ipv4]} to known hosts: #{`#{ssh_command}`}"
      first_deploy = "bundle exec ruby script/first_deploy.rb ubuntu #{droplet[:ipv4]} #{key_path}"
      puts "Executing: #{first_deploy}"
      system(first_deploy)
    end
  end
else
  puts 'Droplets failed'
  puts response.body
end
