# frozen_string_literal: true

RSpec.describe User, type: :model do
  context 'associations' do
    it { is_expected.to have_many :attendances }
    it { is_expected.to have_many :events }
    it { is_expected.to have_and_belong_to_many(:organized_events).class_name('Event') }
    it { is_expected.to have_many(:payment_notifications).through(:attendances).dependent(:destroy) }

    context 'events uniqueness' do
      it 'only show event once if user has multiple attendances' do
        user = FactoryBot.create(:user)
        first_attendance = FactoryBot.create(:attendance, user: user)
        FactoryBot.create(:attendance, user: user, event: first_attendance.event, email: 'foo@bar.com')

        expect(user.events.size).to eq(1)
      end
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }

    it { is_expected.not_to allow_value('').for(:email) }
    it { is_expected.to allow_value('a@a.com').for(:email) }
    it { is_expected.to allow_value('user@domain.com.br').for(:email) }
    it { is_expected.to allow_value('test_user.name@a.co.uk').for(:email) }
    it { is_expected.not_to allow_value('a').for(:email) }
    it { is_expected.not_to allow_value('a@').for(:email) }
    it { is_expected.not_to allow_value('a@a').for(:email) }
    it { is_expected.not_to allow_value('@12.com').for(:email) }

    context 'uniqueness' do
      let!(:user) { FactoryBot.create :user }
      let!(:other_user) { FactoryBot.build :user, email: user.email }
      it { expect(other_user).not_to be_valid }
    end
  end

  context 'virtual attributes' do
    context 'twitter user' do
      it 'removes @ from start if present' do
        user = FactoryBot.build(:user, twitter_user: '@agilebrazil')
        expect(user.twitter_user).to eq('agilebrazil')
      end

      it 'keeps as given if doesnt start with @' do
        user = FactoryBot.build(:user, twitter_user: 'agilebrazil')
        expect(user.twitter_user).to eq('agilebrazil')
      end
    end
  end

  describe '#registrations_for_event' do
    let(:event) { FactoryBot.create :event }
    context 'when having registrations to event and the user' do
      let(:user) { FactoryBot.create :user }

      it 'returns all the registrations' do
        first = FactoryBot.create(:attendance, user: user, event: event, email: Faker::Internet.email)
        second = FactoryBot.create(:attendance, user: user, event: event, email: Faker::Internet.email)
        third = FactoryBot.create(:attendance, user: user, event: event, email: Faker::Internet.email)
        registrations = user.registrations_for_event(event)
        expect(registrations).to match_array [first, second, third]
      end
    end

    context 'when having two users with registrations' do
      let(:user) { FactoryBot.create :user }
      let(:other_user) { FactoryBot.create :user }

      it 'returns all the registrations for the user' do
        first = FactoryBot.create(:attendance, user: user, event: event, email: Faker::Internet.email)
        second = FactoryBot.create(:attendance, user: user, event: event, email: Faker::Internet.email)
        FactoryBot.create(:attendance, user: other_user, event: event)
        registrations = user.registrations_for_event(event)
        expect(registrations).to match_array [first, second]
      end
    end

    context 'when having two events with registrations' do
      let(:user) { FactoryBot.create :user }
      let(:other_event) { FactoryBot.create :event }

      it 'returns all the registrations for the user' do
        first = FactoryBot.create(:attendance, user: user, event: event, email: Faker::Internet.email)
        second = FactoryBot.create(:attendance, user: user, event: event, email: Faker::Internet.email)
        FactoryBot.create(:attendance, user: user, event: other_event)
        registrations = user.registrations_for_event(event)
        expect(registrations).to match_array [first, second]
      end
    end
  end

  describe '#organizer_of?' do
    let(:event) { FactoryBot.create :event }
    let!(:organizer) { FactoryBot.create :organizer, organized_events: [event] }
    let(:user) { FactoryBot.create :user, organized_events: [event] }
    let(:admin) { FactoryBot.create :admin }

    let(:other_event) { FactoryBot.create :event }

    it { expect(organizer.organizer_of?(event)).to be true }
    it { expect(user.organizer_of?(event)).to be false }
    it { expect(organizer.organizer_of?(other_event)).to be false }
    it { expect(admin.organizer_of?(event)).to be true }
    it { expect(admin.organizer_of?(other_event)).to be true }
  end
end
