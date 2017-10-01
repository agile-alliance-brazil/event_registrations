require 'spec_helper'

describe Authentication, type: :model do
  context 'associations' do
    it { should belong_to :user }
  end

  context 'validations' do
    it { should validate_presence_of :provider }
    it { should validate_presence_of :uid }
  end

  describe 'token' do
    let(:authentication) { FactoryGirl.build(:authentication, provider: 'submission_system', refresh_token: 'ABC') }
    let(:new_token)      { stub(refresh_token: 'DEF') }
    let(:token)          { stub(refresh!: new_token) }

    before do
      OAuth2::AccessToken.stubs(:new).returns(token)
    end

    it 'should be nil if refresh_token is not present' do
      authentication.refresh_token = nil
      expect(authentication.token).to be_nil
    end

    it 'should be nil if provider is not submission system' do
      authentication.provider = 'twitter'
      expect(authentication.token).to be_nil

      authentication.provider = 'facebook'
      expect(authentication.token).to be_nil
    end

    it 'should return access token' do
      expect(authentication.token).to eq(new_token)
    end

    it 'should update the refresh_token' do
      authentication.token
      expect(authentication.refresh_token).to eq('DEF')
    end
  end
end
