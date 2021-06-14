# frozen_string_literal: true

RSpec.describe User, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:role).with_values(user: 0, organizer: 1, admin: 2) }
    it { is_expected.to define_enum_for(:gender).with_values(cisgender_man: 0, transgender_man: 1, cisgender_woman: 2, transgender_woman: 3, non_binary: 4, gender_not_informed: 5) }
    it { is_expected.to define_enum_for(:education_level).with_values(no_education_informed: 0, primary: 1, secondary: 2, tec_secondary: 3, tec_terciary: 4, bachelor: 5, master: 6, doctoral: 7) }
    it { is_expected.to define_enum_for(:ethnicity).with_values(no_ethnicity_informed: 0, asian: 1, white: 2, indian: 3, brown: 4, black: 5) }
    it { is_expected.to define_enum_for(:disability).with_values(no_disability: 0, visually_impairment: 1, hearing_impairment: 2, physical_impairment: 3, mental_impairment: 4, disability_not_informed: 5) }
  end

  context 'associations' do
    it { is_expected.to have_many :attendances }
    it { is_expected.to have_many :events }
    it { is_expected.to have_and_belong_to_many(:organized_events).class_name('Event') }
    it { is_expected.to have_many(:payment_notifications).through(:attendances).dependent(:destroy) }
    it { is_expected.to have_many(:led_groups).class_name('RegistrationGroup').dependent(:nullify) }
    it { is_expected.to have_many(:registered_attendances).class_name('Attendance').dependent(:restrict_with_exception) }
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

    context 'events uniqueness' do
      it 'only show event once if user has multiple attendances' do
        user = Fabricate(:user)
        first_attendance = Fabricate(:attendance, user: user)
        Fabricate(:attendance, user: user, event: first_attendance.event)

        expect(user.events.size).to eq(1)
      end
    end

    context 'uniqueness' do
      let!(:user) { Fabricate :user }
      let!(:other_user) { Fabricate.build :user, email: user.email }

      it { expect(other_user).not_to be_valid }
    end
  end

  describe '#registrations_for_event' do
    let(:event) { Fabricate :event }

    context 'when having registrations to event and the user' do
      let(:user) { Fabricate :user }

      it 'returns all the registrations' do
        first = Fabricate(:attendance, user: user, event: event)
        second = Fabricate(:attendance, user: user, event: event)
        third = Fabricate(:attendance, user: user, event: event)
        registrations = user.registrations_for_event(event)
        expect(registrations).to match_array [first, second, third]
      end
    end

    context 'when having two users with registrations' do
      let(:user) { Fabricate :user }
      let(:other_user) { Fabricate :user }

      it 'returns all the registrations for the user' do
        first = Fabricate(:attendance, user: user, event: event)
        second = Fabricate(:attendance, user: user, event: event)
        Fabricate(:attendance, user: other_user, event: event)
        registrations = user.registrations_for_event(event)
        expect(registrations).to match_array [first, second]
      end
    end

    context 'when having two events with registrations' do
      let(:user) { Fabricate :user }
      let(:other_event) { Fabricate :event }

      it 'returns all the registrations for the user' do
        first = Fabricate(:attendance, user: user, event: event)
        second = Fabricate(:attendance, user: user, event: event)
        Fabricate(:attendance, user: user, event: other_event)
        registrations = user.registrations_for_event(event)
        expect(registrations).to match_array [first, second]
      end
    end
  end

  describe '#organizer_of?' do
    let(:event) { Fabricate :event }
    let!(:organizer) { Fabricate :user, role: :organizer, organized_events: [event] }
    let(:user) { Fabricate :user, organized_events: [event] }
    let(:admin) { Fabricate :user, role: :admin }

    let(:other_event) { Fabricate :event }

    it { expect(organizer.organizer_of?(event)).to be true }
    it { expect(user.organizer_of?(event)).to be false }
    it { expect(organizer.organizer_of?(other_event)).to be false }
    it { expect(admin.organizer_of?(event)).to be true }
    it { expect(admin.organizer_of?(other_event)).to be true }
  end

  describe '.from_omniauth' do
    context 'with a valid OmniAuth::AuthHas' do
      context 'when the user does not exist' do
        context 'and the name has two parts' do
          subject(:user) { described_class.from_omniauth(user_hash) }

          let!(:user_hash) { OmniAuth::AuthHash.new(provider: 'twitter', uid: '123545', info: { name: 'foo bar', email: 'foo@bar.com.br' }) }

          it 'creates the user using the attributes' do
            new_user = user.reload
            expect(new_user).to be_persisted
            expect(new_user.first_name).to eq 'foo'
            expect(new_user.last_name).to eq 'bar'
            expect(new_user.email).to eq 'foo@bar.com.br'
          end
        end

        context 'and the name has four parts' do
          subject(:user) { described_class.from_omniauth(user_hash) }

          let!(:user_hash) { OmniAuth::AuthHash.new(provider: 'twitter', uid: '123545', info: { name: 'foo bar xpto bla', email: 'foo@bar.com.br' }) }

          it 'creates the user using the attributes' do
            expect(user).to be_persisted
            expect(user.first_name).to eq 'foo'
            expect(user.last_name).to eq 'bar xpto bla'
            expect(user.email).to eq 'foo@bar.com.br'
          end
        end
      end

      context 'and the name has one part' do
        subject(:user) { described_class.from_omniauth(user_hash) }

        let!(:user_hash) { OmniAuth::AuthHash.new(provider: 'twitter', uid: '123545', info: { name: 'foo', email: 'foo@bar.com.br' }) }

        it 'creates the user using the attributes' do
          expect(user).to be_persisted
          expect(user.first_name).to eq 'foo'
          expect(user.last_name).to eq 'foo'
          expect(user.email).to eq 'foo@bar.com.br'
        end
      end

      context 'having no name' do
        subject(:user) { described_class.from_omniauth(user_hash) }

        let!(:user_hash) { OmniAuth::AuthHash.new(provider: 'twitter', uid: '123545', info: { name: '', email: 'foo@bar.com.br' }) }

        it 'creates the user using the attributes' do
          expect(user).not_to be_persisted
          expect(user.first_name).to eq nil
          expect(user.last_name).to eq nil
          expect(user.email).to eq 'foo@bar.com.br'
        end
      end

      context 'having no email' do
        subject(:user) { described_class.from_omniauth(user_hash) }

        let!(:user_hash) { OmniAuth::AuthHash.new(provider: 'twitter', uid: '123545', info: { name: 'foo bar', email: '' }) }

        it 'creates the user using the attributes' do
          expect(user).not_to be_persisted
          expect(user.first_name).to eq 'foo'
          expect(user.last_name).to eq 'bar'
          expect(user.email).to eq ''
        end
      end
    end
  end

  describe '#toggle_admin' do
    context 'when it is an admin' do
      let(:user) { Fabricate :user, role: :admin }

      before { user.toggle_admin }

      it { expect(described_class.last.admin?).to be false }
      it { expect(described_class.last.user?).to be true }
    end

    context 'when it is not an admin' do
      let(:user) { Fabricate :user, role: :user }

      before { user.toggle_admin }

      it { expect(described_class.last.admin?).to be true }
      it { expect(described_class.last.user?).to be false }
    end
  end

  describe '#toggle_organizer' do
    context 'when it is an organizer' do
      let(:user) { Fabricate :user, role: :organizer }

      before { user.toggle_organizer }

      it { expect(described_class.last.organizer?).to be false }
      it { expect(described_class.last.user?).to be true }
    end

    context 'when it is not an organizer' do
      let(:user) { Fabricate :user, role: :user }

      before { user.toggle_organizer }

      it { expect(described_class.last.organizer?).to be true }
      it { expect(described_class.last.user?).to be false }
    end
  end

  describe '#avatar_valid?' do
    let(:user) { Fabricate :user }

    it 'returns false when the URL is not valid' do
      allow_any_instance_of(RegistrationsImageUploader).to(receive(:blank?)).and_return(false)
      allow(NetServices.instance).to(receive(:url_found?)).and_return(false)
      expect(user.avatar_valid?).to be false
    end

    it 'returns false when the image is null' do
      allow_any_instance_of(RegistrationsImageUploader).to(receive(:blank?)).and_return(true)
      expect(user.avatar_valid?).to be false
    end

    it 'returns true when the URL was found' do
      allow_any_instance_of(RegistrationsImageUploader).to(receive(:blank?)).and_return(false)
      allow(NetServices.instance).to(receive(:url_found?)).and_return(true)
      expect(user.avatar_valid?).to be true
    end
  end

  describe '#registrations_for_other_users' do
    let(:user) { Fabricate :user }
    let(:other_user) { Fabricate :user }
    let(:no_attendances_user) { Fabricate :user }

    it 'returns the registrations for other users' do
      first_attendance = Fabricate :attendance, user: other_user, registered_by_user: user, registration_date: 2.days.ago
      second_attendance = Fabricate :attendance, user: other_user, registered_by_user: user, registration_date: 1.day.ago
      third_attendance = Fabricate :attendance, user: other_user, registered_by_user: user, registration_date: Time.zone.now
      Fabricate :attendance, user: user, registered_by_user: user, registration_date: 4.days.ago
      Fabricate :attendance, user: user, registered_by_user: user, registration_date: 3.days.ago

      expect(user.registrations_for_other_users).to eq [third_attendance, second_attendance, first_attendance]
      expect(other_user.registrations_for_other_users).to eq []
      expect(no_attendances_user.registrations_for_other_users).to eq []
    end
  end
end
