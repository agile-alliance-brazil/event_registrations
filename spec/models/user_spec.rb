# encoding: UTF-8
require 'spec_helper'

describe User do
  context "associations" do
    it { should have_many :authentications }
    it { should have_many :attendances }
    it { should have_many :events }
    it { should have_many :payment_notifications }
  end

  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :first_name }
    it { should allow_mass_assignment_of :last_name }
    it { should allow_mass_assignment_of :email }
    it { should allow_mass_assignment_of :organization }
    it { should allow_mass_assignment_of :phone }
    it { should allow_mass_assignment_of :country }
    it { should allow_mass_assignment_of :state }
    it { should allow_mass_assignment_of :city }
    it { should allow_mass_assignment_of :badge_name }
    it { should allow_mass_assignment_of :cpf }
    it { should allow_mass_assignment_of :gender }
    it { should allow_mass_assignment_of :twitter_user }
    it { should allow_mass_assignment_of :address }
    it { should allow_mass_assignment_of :neighbourhood }
    it { should allow_mass_assignment_of :zipcode }
    it { should allow_mass_assignment_of :registration_type_id }
    it { should allow_mass_assignment_of :status_event }
    it { should allow_mass_assignment_of :event_id }
    it { should allow_mass_assignment_of :payment_agreement }
    it { should allow_mass_assignment_of :registration_date }
    it { should allow_mass_assignment_of :default_locale }
    
    it { should_not allow_mass_assignment_of :id }
    it { should_not allow_mass_assignment_of :active }
    it { should_not allow_mass_assignment_of :roles_mask }
  end

  it_should_trim_attributes User, :first_name, :last_name, :email, :organization, :phone,
                                  :country, :state, :city, :badge_name, :twitter_user,
                                  :address, :neighbourhood, :zipcode
  
  context "validations" do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }

    it { should allow_value("").for(:email) }
    it { should allow_value("a@a.com").for(:email) }
    it { should allow_value("user@domain.com.br").for(:email) }
    it { should allow_value("test_user.name@a.co.uk").for(:email) }
    it { should_not allow_value("a").for(:email) }
    it { should_not allow_value("a@").for(:email) }
    it { should_not allow_value("a@a").for(:email) }
    it { should_not allow_value("@12.com").for(:email) }

    context "uniqueness" do
      it { should validate_uniqueness_of(:email) }
    end
  end

  context "virtual attributes" do                
    context "twitter user" do
      it "should remove @ from start if present" do
        user = FactoryGirl.build(:user, :twitter_user => '@agilebrazil')
        user.twitter_user.should == 'agilebrazil'
      end

      it "should keep as given if doesnt start with @" do
        user = FactoryGirl.build(:user, :twitter_user => 'agilebrazil')
        user.twitter_user.should == 'agilebrazil'
      end
    end
  end
end