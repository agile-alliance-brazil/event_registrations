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

  context "for attendance" do
    before do
      @user = FactoryGirl.build(:user)
    end
    it "should not send id" do
      @user.attendance_attributes.should_not include("id")
    end
    it "should not send created_at" do
      @user.attendance_attributes.should_not include("created_at")
    end
    it "should not send updated_at" do
      @user.attendance_attributes.should_not include("updated_at")
    end
    it "should not send roles_mask" do
      @user.attendance_attributes.should_not include("roles_mask")
    end
    it "should not send default_locale" do
      @user.attendance_attributes.should_not include("default_locale")
    end
    it "should send other attributes" do
      @user.attendance_attributes.should include("first_name")
      @user.attendance_attributes.should include("last_name")
      @user.attendance_attributes.should include("email")
      @user.attendance_attributes.should include("organization")
      @user.attendance_attributes.should include("phone")
      @user.attendance_attributes.should include("country")
      @user.attendance_attributes.should include("state")
      @user.attendance_attributes.should include("city")
      @user.attendance_attributes.should include("badge_name")
      @user.attendance_attributes.should include("cpf")
      @user.attendance_attributes.should include("gender")
      @user.attendance_attributes.should include("twitter_user")
      @user.attendance_attributes.should include("address")
      @user.attendance_attributes.should include("neighbourhood")
      @user.attendance_attributes.should include("zipcode")
    end
  end
end