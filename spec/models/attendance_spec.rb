# encoding: UTF-8
require 'spec_helper'

describe Attendance, type: :model do
  context "associations" do
    it { should belong_to :event }
    it { should belong_to :user }
    it { should belong_to :registration_type }
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

    it { should validate_length_of(:email).is_at_least(6).is_at_most(100) }
    it { should validate_length_of(:first_name).is_at_most(100) }
    it { should validate_length_of(:last_name).is_at_most(100) }
    it { should validate_length_of(:city).is_at_most(100) }
    it { should validate_length_of(:organization).is_at_most(100) }

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
      expect(Attendance.for_event(Attendance.first.event)).to eq([Attendance.first])
    end

    it "should have scope for_registration_type" do
      rt = FactoryGirl.create(:registration_type, :event => Attendance.first.event)
      Attendance.first.tap{|a| a.registration_type = rt}.save

      expect(Attendance.for_registration_type(rt)).to eq([Attendance.first])
    end

    it "should have scope without_registration_type" do
      rt = FactoryGirl.create(:registration_type, :event => Attendance.first.event)
      Attendance.first.tap{|a| a.registration_type = rt}.save

      expect(Attendance.without_registration_type(rt)).not_to include(Attendance.first)
    end

    it "should have scope pending" do
      Attendance.first.tap(&:pay).save
      expect(Attendance.pending).not_to include(Attendance.first)
    end

    it "should have scope paid" do
      Attendance.first.tap(&:pay).save
      expect(Attendance.paid).to eq([Attendance.first])
    end

    it "should have scope active that excludes cancelled attendances" do
      Attendance.first.tap(&:cancel).save
      expect(Attendance.active).not_to include(Attendance.first)
    end

    it "should have scope older_than that selects old attendances" do
      Attendance.first.tap{|a| a.registration_date = 10.days.ago}.save
      expect(Attendance.older_than(5.days.ago)).to eq([Attendance.first])
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

        expect(@attendance.registration_period).to eq(@period)
      end

      it "should regular early bird after 150 attendances" do
        @attendance.event.expects(:attendances)
                  .returns(stub(count: 150))
        @attendance.event.registration_periods.expects(:for).with(@period.end_at + 1.day).returns([])

        expect(@attendance.registration_period).not_to eq(@period)
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

        expect(@attendance.registration_period).to eq(@period)
      end
      
      it "should be 399 after 150 attendances" do
        @attendance.id = 150

        @attendance.event.expects(:attendances)
                  .returns(stub(where: stub(count: 150)))
        @attendance.event.registration_periods.expects(:for).with(@period.end_at + 1.day).returns([])

        expect(@attendance.registration_period).not_to eq(@period)
      end
    end
  end

  describe "can_vote?" do
    let(:attendance) { FactoryGirl.build(:attendance) }

    it "should be true if attendance paid" do
      period = FactoryGirl.build(:registration_period)
      period.stubs(:allow_voting?).returns(true)

      attendance.event.registration_periods.stubs(:for).returns([period])

      expect(attendance).not_to be_can_vote
      attendance.pay
      expect(attendance).to be_can_vote
    end

    it "should be true if attendance confirmed" do
      period = FactoryGirl.build(:registration_period)
      period.stubs(:allow_voting?).returns(true)

      attendance.event.registration_periods.stubs(:for).returns([period])
      
      expect(attendance).not_to be_can_vote
      attendance.confirm
      expect(attendance).to be_can_vote
    end

    it "should be true if registration period allows voting" do
      period = FactoryGirl.build(:registration_period)
      period.expects(:allow_voting?).twice.returns(false, true)

      attendance.event.registration_periods.stubs(:for).returns([period])
      attendance.confirm

      expect(attendance).not_to be_can_vote
      expect(attendance).to be_can_vote
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
      expect(attendance).to be_cancellable
    end
    it "should not be cancellable if paid" do
      attendance.pay
      expect(attendance).not_to be_cancellable
    end
    it "should not be cancellable if confirmed" do
      attendance.pay
      attendance.confirm
      expect(attendance).not_to be_cancellable
    end
    it "should not be cancellable if cancelled already" do
      attendance.cancel
      expect(attendance).not_to be_cancellable
    end
  end
end
