describe User, type: :model do
  context 'associations' do
    it { is_expected.to have_many :authentications }
    it { is_expected.to have_many :attendances }
    it { is_expected.to have_many :events }
    it { is_expected.to have_many :payment_notifications }
    it { is_expected.to have_and_belong_to_many(:organized_events).class_name('Event') }

    context 'events uniqueness' do
      it 'only show event once if user has multiple attendances' do
        user = FactoryBot.create(:user)
        first_attendance = FactoryBot.create(:attendance, user: user)
        FactoryBot.create(:attendance, user: user, event: first_attendance.event)

        expect(user.events.size).to eq(1)
      end
    end
  end

  it_should_trim_attributes User, :first_name, :last_name, :email, :organization, :phone,
                            :country, :state, :city, :badge_name, :twitter_user,
                            :address, :neighbourhood, :zipcode

  context 'validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }

    it { is_expected.to allow_value('').for(:email) }
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

  context 'new from auth hash' do
    it 'initializes user with names and email' do
      hash = { info: { name: 'John Doe', email: 'john@doe.com' } }
      user = User.new_from_auth_hash(hash)
      expect(user.first_name).to eq('John')
      expect(user.last_name).to eq('Doe')
      expect(user.email).to eq('john@doe.com')
    end

    it 'works without name and email' do
      hash = { info: { email: 'john@doe.com' } }
      user = User.new_from_auth_hash(hash)
      expect(user.first_name).to be_nil
      expect(user.last_name).to be_nil
      expect(user.email).to eq('john@doe.com')
    end

    it 'prefers first and last name rather than name' do
      hash = { info: { email: 'john@doe.com', name: 'John of Doe', first_name: 'John', last_name: 'of Doe' } }
      user = User.new_from_auth_hash(hash)
      expect(user.first_name).to eq('John')
      expect(user.last_name).to eq('of Doe')
      expect(user.email).to eq('john@doe.com')
    end

    it 'assigns twitter_user if using twitter as provider' do
      hash = { info: { name: 'John Doe', email: 'john@doe.com', nickname: 'johndoe' }, provider: 'twitter' }
      user = User.new_from_auth_hash(hash)
      expect(user.twitter_user).to eq('johndoe')
    end

    it 'works when more information is passed' do
      hash = { info: {
        first_name: 'John',
        last_name: 'Doe',
        email: 'john@doe.com',
        twitter_user: '@jdoe',
        organization: 'Company',
        phone: '12342',
        country: 'BR',
        state: 'SP',
        city: 'São Paulo'
      } }
      user = User.new_from_auth_hash(hash)
      expect(user.first_name).to eq('John')
      expect(user.last_name).to eq('Doe')
      expect(user.email).to eq('john@doe.com')
      expect(user.twitter_user).to eq('jdoe')
      expect(user.organization).to eq('Company')
      expect(user.phone).to eq('12342')
      expect(user.country).to eq('BR')
      expect(user.state).to eq('SP')
      expect(user.city).to eq('São Paulo')
    end

    context 'no email informed by auth provider' do
      let(:hash) { { info: { name: 'John Doe', email: nil } } }
      let(:user) { FactoryBot.create(:user, email: nil) }
      subject(:user_from_hash) { User.new_from_auth_hash(hash) }
      it { expect(user_from_hash).not_to eq user }
    end
    context 'email informed by auth provider' do
      let(:hash) { { info: { name: 'John Doe', email: 'bla@xpto.com' } } }
      let!(:user) { FactoryBot.create(:user, email: 'bla@xpto.com') }
      subject(:user_from_hash) { User.new_from_auth_hash(hash) }
      it { expect(user_from_hash).to eq user }
    end
  end

  describe '#registrations_for_event' do
    let(:event) { FactoryBot.create :event }
    context 'when having registrations to event and the user' do
      let(:user) { FactoryBot.create :user }

      it 'returns all the registrations' do
        first = FactoryBot.create(:attendance, user: user, event: event)
        second = FactoryBot.create(:attendance, user: user, event: event)
        third = FactoryBot.create(:attendance, user: user, event: event)
        registrations = user.registrations_for_event(event)
        expect(registrations).to match_array [first, second, third]
      end
    end

    context 'when having two users with registrations' do
      let(:user) { FactoryBot.create :user }
      let(:other_user) { FactoryBot.create :user }

      it 'returns all the registrations for the user' do
        first = FactoryBot.create(:attendance, user: user, event: event)
        second = FactoryBot.create(:attendance, user: user, event: event)
        FactoryBot.create(:attendance, user: other_user, event: event)
        registrations = user.registrations_for_event(event)
        expect(registrations).to match_array [first, second]
      end
    end

    context 'when having two events with registrations' do
      let(:user) { FactoryBot.create :user }
      let(:other_event) { FactoryBot.create :event }

      it 'returns all the registrations for the user' do
        first = FactoryBot.create(:attendance, user: user, event: event)
        second = FactoryBot.create(:attendance, user: user, event: event)
        FactoryBot.create(:attendance, user: user, event: other_event)
        registrations = user.registrations_for_event(event)
        expect(registrations).to match_array [first, second]
      end
    end
  end

  describe '#organized_user_present?' do
    let(:event) { FactoryBot.create :event }
    let!(:organizer) { FactoryBot.create :organizer, organized_events: [event] }
    let(:user) { FactoryBot.create :user }
    let!(:attendance) { FactoryBot.create :attendance, user: user, event: event }

    let(:other_event) { FactoryBot.create :event }
    let(:other_user) { FactoryBot.create :user }
    let!(:other_attendance) { FactoryBot.create :attendance, user: other_user, event: other_event }

    it { expect(organizer.organized_user_present?(user)).to be_truthy }
    it { expect(organizer.organized_user_present?(other_user)).to be_falsey }
  end
end
