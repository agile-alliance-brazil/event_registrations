require 'spec_helper'

require File.expand_path('lib/omniauth/strategies/submission_system', Rails.root)

describe OmniAuth::Strategies::SubmissionSystem do
  before { OmniAuth.config.test_mode = true }
  after { OmniAuth.config.test_mode = false }
  let(:fresh_strategy) { OmniAuth::Strategies::SubmissionSystem.new(APP_CONFIG[:submission_system][:key], APP_CONFIG[:submission_system][:secret], :client_options => { :ssl => { :ca_path => '/etc/ssl/certs' } }) }

  context 'submission strategy' do
    context 'with all data fulfilled' do
      subject { fresh_strategy }
      it 'mounts the info based on raw_info' do
        client = OAuth2::Client.new(1, 'secret')
        access_token = OAuth2::AccessToken.new(client, { access_token: 'foo' })
        OmniAuth::Strategies::OAuth2.any_instance.expects(:access_token).returns access_token
        response = OAuth2::Response.new('foo')
        response_parsed =
          {
            'first_name' => 'first_name',
            'last_name' => 'last_name',
            'email' => 'email@email.com',
            'twitter_username' => 'twitter_user',
            'organization' => 'organization',
            'phone' => 'phone',
            'country' => 'country',
            'state' => 'state',
            'city' => 'city'
          }

        OAuth2::AccessToken.any_instance.expects(:get).with(instance_of(String)).returns response
        OAuth2::Response.any_instance.expects(:parsed).returns(response_parsed)

        info_expected =
          {
            :first_name => 'first_name',
            :last_name => 'last_name',
            :email => 'email@email.com',
            :twitter_user => 'twitter_user',
            :organization => 'organization',
            :phone => 'phone',
            :country => 'country',
            :state => 'state',
            :city => 'city'
          }
        expect(fresh_strategy.info).to eq info_expected
      end

      context 'with no data fulfilled' do
        subject { fresh_strategy }
        it 'mounts the info based on raw_info even with null values' do
          client = OAuth2::Client.new(1, 'secret')
          access_token = OAuth2::AccessToken.new(client, { access_token: 'foo' })
          OmniAuth::Strategies::OAuth2.any_instance.expects(:access_token).returns access_token
          response = OAuth2::Response.new('foo')
          response_parsed = {}

          OAuth2::AccessToken.any_instance.expects(:get).with(instance_of(String)).returns response
          OAuth2::Response.any_instance.expects(:parsed).returns(response_parsed)

          info_expected =
            {
              :first_name => nil,
              :last_name => nil,
              :email => nil,
              :twitter_user => nil,
              :organization => nil,
              :phone => nil,
              :country => nil,
              :state => nil,
              :city => nil
            }
          expect(fresh_strategy.info).to eq info_expected
        end
      end
    end
  end
end