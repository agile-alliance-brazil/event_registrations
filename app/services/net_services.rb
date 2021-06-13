# frozen_string_literal: true

class NetServices
  include Singleton

  def url_found?(url_to_check)
    url = URI.parse(url_to_check)
    req = Net::HTTP.new(url.host, url.port)
    req.use_ssl = (url.scheme == 'https')
    path = url.path if url.path.present?
    res = req.request_head(path || '/')
    res.code != '404'
  rescue Errno::ENOENT
    false
  end
end
