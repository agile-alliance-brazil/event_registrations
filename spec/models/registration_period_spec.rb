# encoding: UTF-8
require 'spec_helper'

describe RegistrationPeriod, type: :model do
  before do
    @event = FactoryGirl.create(:event)
    @regular = @event.registration_periods.first

    @super_early_bird = FactoryGirl.create(:registration_period, event: @event, title: 'registration_period.super_early_bird', start_at: Time.zone.local(2013, 01, 01), end_at: Time.zone.local(2013, 01, 31).end_of_day)
    @early_bird = FactoryGirl.create(:registration_period, event: @event, title: 'registration_period.early_bird', start_at: Time.zone.local(2013, 02, 01), end_at: Time.zone.local(2013, 02, 28).end_of_day)

    @regular.start_at = Time.zone.local(2013, 03, 01)
    @regular.end_at = Time.zone.local(2013, 03, 31).end_of_day
    @regular.save

    @late = FactoryGirl.create(:registration_period, event: @event, title: 'registration_period.late', start_at: Time.zone.local(2013, 04, 01), end_at: Time.zone.local(2013, 04, 30).end_of_day)
    @last_minute = FactoryGirl.create(:registration_period, event: @event, title: 'registration_period.last_minute', start_at: Time.zone.local(2013, 05, 01), end_at: Time.zone.local(3013, 05, 31).end_of_day)
  end

  context 'prices' do
    it 'should be super_early_bird if title matches' do
      expect(@super_early_bird).to be_super_early_bird
      expect(@early_bird).not_to be_super_early_bird
      expect(@regular).not_to be_super_early_bird
      expect(@late).not_to be_super_early_bird
      expect(@last_minute).not_to be_super_early_bird
    end

    context 'for registration types' do
      before do
        @individual = @event.registration_types.first
      end

      it 'should delegate to RegistrationPrice' do
        price = RegistrationPrice.new
        price.value = 250
        RegistrationPrice.stubs(:for).returns([price])
        expect(@super_early_bird.price_for).to eq(250.00)
      end

      it 'should throw an InvalidPrice error if no registration price can be found' do
        RegistrationPrice.stubs(:for).returns([])
        expect(-> { @super_early_bird.price_for }).to raise_error(InvalidPrice)
      end
    end
  end

  context 'appropriate period' do
    it 'should not include date before its start' do
      expect(RegistrationPeriod.for(@regular.start_at - 1.second).first).to eq(@early_bird)
    end

    it 'should include its start date' do
      expect(RegistrationPeriod.for(@regular.start_at).first).to eq(@regular)
    end

    it 'should include a date between start and end' do
      expect(RegistrationPeriod.for(@regular.start_at + 5).first).to eq(@regular)
    end

    it 'should include end date' do
      expect(RegistrationPeriod.for(@regular.end_at).first).to eq(@regular)
    end

    it 'should not include date after end date' do
      expect(RegistrationPeriod.for(@regular.end_at + 1.week).first).to eq(@late)
    end

    # TODO: Crappy test depends on other events not starting before this.
    it 'should not have any period before super_early_bird' do
      expect(RegistrationPeriod.for(@super_early_bird.start_at - 1.second).first).to be_nil
    end

    # TODO: Crappy test depends on other events not finishing after this.
    it 'should not have any period after last minute' do
      expect(RegistrationPeriod.for(@last_minute.end_at + 1.second).first).to be_nil
    end
  end

  describe 'boolean tests' do
    subject { FactoryGirl.build(:registration_period) }

    it { should_not be_super_early_bird }
    it { should_not be_early_bird }
    it { should_not be_allow_voting }

    context 'super early bird' do
      before { subject.title = 'registration_period.super_early_bird' }
      it { should be_super_early_bird }
    end

    context 'early bird' do
      before { subject.title = 'registration_period.early_bird' }
      it { should be_early_bird }
    end

    context 'allow voting' do
      it 'should be false when event does not allow voting' do
        subject.event.allow_voting = false
        expect(subject).not_to be_allow_voting
      end

      it 'should be true for super early bird' do
        subject.event.allow_voting = true
        expect(subject).not_to be_allow_voting
        subject.title = 'registration_period.super_early_bird'
        expect(subject).to be_allow_voting
      end

      it 'should be true for early bird' do
        subject.event.allow_voting = true
        expect(subject).not_to be_allow_voting
        subject.title = 'registration_period.early_bird'
        expect(subject).to be_allow_voting
      end
    end
  end
end
