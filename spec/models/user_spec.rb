# encoding: UTF-8
require 'spec_helper'

describe User, type: :model do
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

        expect(user.events.size).to eq(1)
      end
    end
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
        expect(user.twitter_user).to eq('agilebrazil')
      end

      it "should keep as given if doesnt start with @" do
        user = FactoryGirl.build(:user, :twitter_user => 'agilebrazil')
        expect(user.twitter_user).to eq('agilebrazil')
      end
    end
  end

  context "for attendance" do
    before do
      @user = FactoryGirl.build(:user)
    end
    it "should not send id" do
      expect(@user.attendance_attributes).not_to include("id")
    end
    it "should not send created_at" do
      expect(@user.attendance_attributes).not_to include("created_at")
    end
    it "should not send updated_at" do
      expect(@user.attendance_attributes).not_to include("updated_at")
    end
    it "should not send roles_mask" do
      expect(@user.attendance_attributes).not_to include("roles_mask")
    end
    it "should not send default_locale" do
      expect(@user.attendance_attributes).not_to include("default_locale")
    end
    it "should send other attributes" do
      expect(@user.attendance_attributes).to include("first_name")
      expect(@user.attendance_attributes).to include("last_name")
      expect(@user.attendance_attributes).to include("email")
      expect(@user.attendance_attributes).to include("organization")
      expect(@user.attendance_attributes).to include("phone")
      expect(@user.attendance_attributes).to include("country")
      expect(@user.attendance_attributes).to include("state")
      expect(@user.attendance_attributes).to include("city")
      expect(@user.attendance_attributes).to include("badge_name")
      expect(@user.attendance_attributes).to include("cpf")
      expect(@user.attendance_attributes).to include("gender")
      expect(@user.attendance_attributes).to include("twitter_user")
      expect(@user.attendance_attributes).to include("address")
      expect(@user.attendance_attributes).to include("neighbourhood")
      expect(@user.attendance_attributes).to include("zipcode")
    end
  end

  context "new from auth hash" do
    it "should initialize user with names and email" do
      hash = {info: {name: "John Doe", email: "john@doe.com"}}
      user = User.new_from_auth_hash(hash)
      expect(user.first_name).to eq("John")
      expect(user.last_name).to eq("Doe")
      expect(user.email).to eq("john@doe.com")
    end

    it "should work without name and email" do
      hash = {info: {email: "john@doe.com"}}
      user = User.new_from_auth_hash(hash)
      expect(user.first_name).to be_nil
      expect(user.last_name).to be_nil
      expect(user.email).to eq("john@doe.com")
    end

    it "should prefer first and last name rather than name" do
      hash = {info: {email: "john@doe.com", name: "John of Doe", first_name: "John", last_name: "of Doe"}}
      user = User.new_from_auth_hash(hash)
      expect(user.first_name).to eq("John")
      expect(user.last_name).to eq("of Doe")
      expect(user.email).to eq("john@doe.com")
    end

    it "should assign twitter_user if using twitter as provider" do
      hash = {info: {name: "John Doe", email: "john@doe.com", nickname: "johndoe"}, provider: 'twitter'}
      user = User.new_from_auth_hash(hash)
      expect(user.twitter_user).to eq("johndoe")
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
      expect(user.first_name).to eq("John")
      expect(user.last_name).to eq("Doe")
      expect(user.email).to eq("john@doe.com")
      expect(user.twitter_user).to eq("jdoe")
      expect(user.organization).to eq("Company")
      expect(user.phone).to eq("12342")
      expect(user.country).to eq("BR")
      expect(user.state).to eq("SP")
      expect(user.city).to eq("São Paulo")
    end
  end
end