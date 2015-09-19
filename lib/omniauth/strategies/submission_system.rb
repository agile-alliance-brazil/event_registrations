module OmniAuth
  module Strategies
    class SubmissionSystem < OmniAuth::Strategies::OAuth2
      option :name, :submission_system

      option :client_options, {
        :site => APP_CONFIG[:submission_system][:url],
        :authorize_url => '/oauth/authorize'
      }

      uid { raw_info['id'] }

      info do
        {
          :first_name => raw_info['first_name'],
          :last_name => raw_info['last_name'],
          :email => raw_info['email'],
          :twitter_user => raw_info['twitter_username'],
          :organization => raw_info['organization'],
          :phone => raw_info['phone'],
          :country => raw_info['country'],
          :state => raw_info['state'],
          :city => raw_info['city']
         }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/user').parsed
      end
    end
  end
end