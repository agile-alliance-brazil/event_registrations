# encoding: UTF-8
require 'spec_helper'

describe User do
  context "associations" do
    it { should have_many :authentications }
    it { should have_many :attendances }
    it { should have_many :events }
    it { should have_many :payment_notifications }

    context "events uniqueness" do
      it "should only show event once if user has multiple attendances" do
        user = FactoryGirl.create(:user)
        first_attendance = FactoryGirl.create(:attendance, user: user)
        second_attendance = FactoryGirl.create(:attendance, user: user, event: first_attendance.event)

        user.events.size.should == 1
      end
    end
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

  context "new from auth hash" do
    it "should initialize user with names and email" do
      hash = {info: {name: "John Doe", email: "john@doe.com"}}
      user = User.new_from_auth_hash(hash)
      user.first_name.should == "John"
      user.last_name.should == "Doe"
      user.email.should == "john@doe.com"
    end

    it "should work without name and email" do
      hash = {info: {email: "john@doe.com"}}
      user = User.new_from_auth_hash(hash)
      user.first_name.should be_nil
      user.last_name.should be_nil
      user.email.should == "john@doe.com"
    end

    it "should prefer first and last name rather than name" do
      hash = {info: {email: "john@doe.com", name: "John of Doe", first_name: "John", last_name: "of Doe"}}
      user = User.new_from_auth_hash(hash)
      user.first_name.should == "John"
      user.last_name.should == "of Doe"
      user.email.should == "john@doe.com"
    end

    it "should assign twitter_user if using twitter as provider" do
      hash = {info: {name: "John Doe", email: "john@doe.com", nickname: "johndoe"}, provider: 'twitter'}
      user = User.new_from_auth_hash(hash)
      user.twitter_user.should == "johndoe"
    end

    it "should work when more information is passed" do
      hash = {info: {
        :first_name => "John",
        :last_name => "Doe",
        :email => "john@doe.com",
        :twitter_user => "@jdoe",
        :organization => "Company",
        :phone => "12342",
        :country => "BR",
        :state => "SP",
        :city => "São Paulo"
      }}
      user = User.new_from_auth_hash(hash)
      user.first_name.should == "John"
      user.last_name.should == "Doe"
      user.email.should == "john@doe.com"
      user.twitter_user.should == "jdoe"
      user.organization.should == "Company"
      user.phone.should == "12342"
      user.country.should == "BR"
      user.state.should == "SP"
      user.city.should == "São Paulo"
    end
  end
end