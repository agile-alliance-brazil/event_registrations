# encoding: UTF-8
require 'spec_helper'

describe Attendance do
  context "associations" do
    it { should belong_to :event }
    it { should belong_to :user }
    it { should belong_to :registration_type }
  end

  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :event_id }
    it { should allow_mass_assignment_of :user_id }
    it { should allow_mass_assignment_of :registration_type_id }
    it { should allow_mass_assignment_of :registration_date }
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
    
    it { should_not allow_mass_assignment_of :id }
  end

  context "validations" do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :email }
    it { should validate_presence_of :organization }
    it { should validate_presence_of :phone }
    it { should validate_presence_of :country }
    it { should validate_presence_of :city }

    it { should allow_value("1234-2345").for(:phone) }
    it { should allow_value("+55 11 5555 2234").for(:phone) }
    it { should allow_value("+1 (304) 543.3333").for(:phone) }
    it { should allow_value("07753423456").for(:phone) }
    it { should_not allow_value("a").for(:phone) }
    it { should_not allow_value("1234-bfd").for(:phone) }
    it { should_not allow_value(")(*&^%$@!").for(:phone) }
    it { should_not allow_value("[=+]").for(:phone) }

    context "brazilians" do
      subject { FactoryGirl.build(:attendance, :country => "BR") }
      it { should validate_presence_of :state }
      it { should validate_presence_of :cpf }
    end

    context "foreigners" do
      subject { FactoryGirl.build(:attendance, :country => "US") }
      it { should_not validate_presence_of :state }
      it { should_not validate_presence_of :cpf }
    end

    it { should ensure_length_of(:email).is_at_least(6).is_at_most(100) }
    it { should ensure_length_of(:first_name).is_at_most(100) }
    it { should ensure_length_of(:last_name).is_at_most(100) }
    it { should ensure_length_of(:city).is_at_most(100) }
    it { should ensure_length_of(:organization).is_at_most(100) }

    it { should allow_value("user@domain.com.br").for(:email) }
    it { should allow_value("test_user.name@a.co.uk").for(:email) }
    it { should_not allow_value("a").for(:email) }
    it { should_not allow_value("a@").for(:email) }
    it { should_not allow_value("a@a").for(:email) }
    it { should_not allow_value("@12.com").for(:email) }

    xit { should validate_confirmation_of :password }
  end

  context "scopes" do
    before do
      5.times do
        FactoryGirl.create(:attendance)
      end
    end

    it "should have scope for_event" do
      Attendance.for_event(Attendance.first.event).should == [Attendance.first]
    end
    
    it "should have scope for_registration_type" do
      Attendance.first.tap{|a| a.registration_type_id = 3}.save

      Attendance.for_registration_type(RegistrationType.find(3)).should == [Attendance.first]
    end
    
    it "should have scope pending" do
      Attendance.first.tap{|a| a.pay}.save
      Attendance.pending.should_not include(Attendance.first)
    end
    
    it "should have scope paid" do
      Attendance.first.tap{|a| a.pay}.save
      Attendance.paid.should == [Attendance.first]
    end
  end

  context "registrarion period regarding super_early_bird" do
    before do
      @attendance = FactoryGirl.build(:attendance, registration_date: Time.zone.local(2013, 03, 21))
      @super_early_bird = RegistrationPeriod.find_by_title('registration_period.super_early_bird')
      @early_bird = RegistrationPeriod.find_by_title('registration_period.early_bird')
    end

    context "unsaved attendance" do
      it "should be super early bird for 149 attendances (pending, paid or confirmed)" do
        @attendance.event.expects(:attendances)
                  .returns(stub(count: 149))

        @attendance.registration_period.should == @super_early_bird
      end
      
      it "should regular early bird after 150 attendances" do
        @attendance.event.expects(:attendances)
                  .returns(stub(count: 150))

        @attendance.registration_period.should == @early_bird
      end
    end

    context "saved attendance" do
      before do
        @attendance.stubs(:new_record?).returns(false)
      end

      it "should be 250 for 149 attendances before this one (pending, paid or confirmed)" do
        @attendance.id = 149

        @attendance.event.expects(:attendances)
                  .returns(stub(where: stub(count: 149)))

        @attendance.registration_period.should == @super_early_bird
      end
      
      it "should be 399 after 150 attendances" do
        @attendance.id = 150

        @attendance.event.expects(:attendances)
                  .returns(stub(where: stub(count: 150)))

        @attendance.registration_period.should == @early_bird
      end
    end
  end

  context "state machine" do
    it "should start pending"
    it "should move to paid upon payment"
    it "should be confirmed on confirmation"
    it "should email upon after confirmed"
    it "should validate payment agreement when confirmed"
  end

  context "fees" do
    it "should have registration fee according to registration period"
  end

  context "cancelling" do
    it "should be cancelable if pending"
    it "should be cancelable if paid"
    it "should be cancelable if paid"
    it "should be cancelable if confirmed"
    it "should not be cancelable if canceled already"
    it "should not be cancelable few days before the event"
    it "should reimburse part of payment if canceled"
  end
end
