module PagSeguro
  module Request
    extend self
    extend Forwardable

    # Delegates the <tt>:config</tt> and <tt>:configure</tt> methods
    # to the <tt>:request</tt> method, which returns a Aitch::Namespace instance.
    def_delegators :request, :config, :configure

    # Perform a GET request.
    #
    # # +path+: the path that will be requested. Must be something like <tt>"transactions/code/739D69-79C052C05280-55542D9FBB33-CAB2B1"</tt>.
    # # +api_version+: the current PagSeguro API version of the requested service
    # # +data+: the data that will be sent as query string. Must be a Hash.
    # # +headers+: any additional header that will be sent through the request.
    #
    def get(path, api_version, data = {}, headers = {})
      execute :get, path, api_version, data, headers
    end

    # Perform a POST request.
    #
    # # +path+: the path that will be requested. Must be something like <tt>"checkout"</tt>.
    # # +api_version+: the current PagSeguro API version of the requested service
    # # +data+: the data that will be sent as body data. Must be a Hash.
    # # +headers+: any additional header that will be sent through the request.
    #
    def post(path, api_version, data = {}, headers = {})
      execute :post, path, api_version, data, headers
    end

    # Perform the specified HTTP request. It will include the API credentials,
    # api_version, encoding and additional headers.
    def execute(request_method, path, api_version, data, headers) # :nodoc:
      request.public_send(
        request_method,
        PagSeguro.api_url("#{api_version}/#{path}"),
        extended_data(data),
        extended_headers(request_method, headers)
      )
    end

    private
    def request
      @request ||= Aitch::Namespace.new
    end

    def extended_data(data)
      data.merge(
        email: data[:email] || PagSeguro.email,
        token: data[:token] || PagSeguro.token,
        charset: PagSeguro.encoding
      )
    end

    def extended_headers(request_method, headers)
      headers.merge __send__("headers_for_#{request_method}")
    end

    def headers_for_post
      {
        "Accept-Charset" => PagSeguro.encoding,
        "Content-Type" => "application/x-www-form-urlencoded; charset=#{PagSeguro.encoding}"
      }
    end

    def headers_for_get
      {
        "Accept-Charset" => PagSeguro.encoding
      }
    end
  end

  Request.configure do |config|
    config.default_headers = {
      "lib-description"             => "ruby:#{PagSeguro::VERSION}",
      "language-engine-description" => "ruby:#{RUBY_VERSION}"
    }
  end
end
