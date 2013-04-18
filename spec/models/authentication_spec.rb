# encoding: UTF-8
require 'spec_helper'

describe Authentication do
  context "associations" do
    it { should belong_to :user }
  end

  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :provider }
    it { should allow_mass_assignment_of :uid }
  end

  context "validations" do
    it { should validate_presence_of :provider }
    it { should validate_presence_of :uid }
  end

  describe "get_token" do
    let(:authentication) { FactoryGirl.build(:authentication, :provider => 'submission_system', :refresh_token => "ABC") }
    let(:new_token)      { stub(:refresh_token => "DEF") }
    let(:token)          { stub(:refresh! => new_token) }

    before do
      OAuth2::AccessToken.stubs(:new).returns(token)
    end

    it "should be nil if refresh_token is not present" do
      authentication.refresh_token = nil
      authentication.get_token.should be_nil
    end

    it "should be nil if provider is not submission system" do
      authentication.provider = 'twitter'
      authentication.get_token.should be_nil

      authentication.provider = 'facebook'
      authentication.get_token.should be_nil
    end

    it "should return access token" do
      authentication.get_token.should == new_token
    end

    it "should update the refresh_token" do
      authentication.get_token
      authentication.refresh_token.should == "DEF"
    end
  end
end