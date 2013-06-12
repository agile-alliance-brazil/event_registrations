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
    it { should allow_mass_assignment_of :notes }
    
    it { should_not allow_mass_assignment_of :id }
  end

  context "validations" do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :email }
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
      rt = FactoryGirl.create(:registration_type, :event => Attendance.first.event)
      Attendance.first.tap{|a| a.registration_type = rt}.save

      Attendance.for_registration_type(rt).should == [Attendance.first]
    end

    it "should have scope without_registration_type" do
      rt = FactoryGirl.create(:registration_type, :event => Attendance.first.event)
      Attendance.first.tap{|a| a.registration_type = rt}.save

      Attendance.without_registration_type(rt).should_not include(Attendance.first)
    end

    it "should have scope pending" do
      Attendance.first.tap{|a| a.pay}.save
      Attendance.pending.should_not include(Attendance.first)
    end

    it "should have scope paid" do
      Attendance.first.tap{|a| a.pay}.save
      Attendance.paid.should == [Attendance.first]
    end

    it "should have scope active that excludes cancelled attendances" do
      Attendance.first.tap{|a| a.cancel}.save
      Attendance.active.should_not include(Attendance.first)
    end

    it "should have scope older_than that selects old attendances" do
      Attendance.first.tap{|a| a.registration_date = 10.days.ago}.save
      Attendance.older_than(5.days.ago).should == [Attendance.first]
    end
  end

  context "registration period regarding super_early_bird" do
    before do
      @attendance = FactoryGirl.build(:attendance)
      @period = RegistrationPeriod.new
      @period.end_at = Time.zone.local(2000, 1, 1)
      @period.stubs(:super_early_bird?).returns(true)
      @attendance.event.registration_periods.expects(:for).with(@attendance.registration_date).returns([@period])
    end

    context "unsaved attendance" do
      it "should be super early bird for 149 attendances (pending, paid or confirmed)" do
        @attendance.event.expects(:attendances)
                  .returns(stub(count: 149))

        @attendance.registration_period.should == @period
      end

      it "should regular early bird after 150 attendances" do
        @attendance.event.expects(:attendances)
                  .returns(stub(count: 150))
        @attendance.event.registration_periods.expects(:for).with(@period.end_at + 1.day).returns([])

        @attendance.registration_period.should_not == @period
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

        @attendance.registration_period.should == @period
      end
      
      it "should be 399 after 150 attendances" do
        @attendance.id = 150

        @attendance.event.expects(:attendances)
                  .returns(stub(where: stub(count: 150)))
        @attendance.event.registration_periods.expects(:for).with(@period.end_at + 1.day).returns([])

        @attendance.registration_period.should_not == @period
      end
    end
  end

  describe "can_vote?" do
    let(:attendance) { FactoryGirl.build(:attendance) }

    it "should be true if attendance paid" do
      period = FactoryGirl.build(:registration_period)
      period.stubs(:allow_voting?).returns(true)

      attendance.event.registration_periods.stubs(:for).returns([period])

      attendance.should_not be_can_vote
      attendance.pay
      attendance.should be_can_vote
    end

    it "should be true if attendance confirmed" do
      period = FactoryGirl.build(:registration_period)
      period.stubs(:allow_voting?).returns(true)

      attendance.event.registration_periods.stubs(:for).returns([period])
      
      attendance.should_not be_can_vote
      attendance.confirm
      attendance.should be_can_vote
    end

    it "should be true if registration period allows voting" do
      period = FactoryGirl.build(:registration_period)
      period.expects(:allow_voting?).twice.returns(false, true)

      attendance.event.registration_periods.stubs(:for).returns([period])
      attendance.confirm

      attendance.should_not be_can_vote
      attendance.should be_can_vote
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
    let(:attendance) { FactoryGirl.build(:attendance) }
    it "should be cancellable if pending" do
      attendance.should be_cancellable
    end
    it "should not be cancellable if paid" do
      attendance.pay
      attendance.should_not be_cancellable
    end
    it "should not be cancellable if confirmed" do
      attendance.pay
      attendance.confirm
      attendance.should_not be_cancellable
    end
    it "should not be cancellable if cancelled already" do
      attendance.cancel
      attendance.should_not be_cancellable
    end
  end
end
