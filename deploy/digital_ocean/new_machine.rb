#!/usr/bin/env ruby

require 'json'
require 'net/https'
require 'uri'

unless ENV['TOKEN']
  puts "Ensure you've set the Digital ocean token using \"export TOKEN='your_token'\""
  exit 1
end

TOKEN = ENV['TOKEN']
TYPE = :staging
NUMBER = 01
staging = TYPE != :production
SSH = staging ? '36:18:0e:5c:aa:0c:58:9e:d2:72:5b:f7:f8:e7:f2:5d' : 'ba:49:c2:40:4e:18:dd:cb:bb:cd:9c:f6:99:11:67:db'

ROOT = File.join(File.dirname(__FILE__), '../../')

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

bootstrap_info = File.read(File.join(ROOT, 'puppet/script/server_bootstrap.sh'))
body = {
  names: ["inscricoes-#{NUMBER}#{staging ? '-staging' : ''}.agilebrazil.com"],
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
  droplet_infos = ids.map do |id|
    info = get_json("https://api.digitalocean.com/v2/droplets/#{id}")
    if info.code.to_i < 400
      JSON.parse(info.body)
    else
      info.body
    end
  end
  errors, successes = droplets.partition { |i| i.is_a? String }
  puts 'Unknown droplets:'
  puts errors
  puts 'Successes:'
  puts successes.map do |d|
    [
      d['droplet']['id'],
      d['droplet']['networks']['v4'].map { |i| i['ip_address'] },
      d['droplet']['networks']['v6'].map { |i| i['ip_address'] }
    ]
  end
else
  puts 'Droplets failed'
  puts response.body
end
