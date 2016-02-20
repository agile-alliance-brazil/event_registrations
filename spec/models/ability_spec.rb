describe Ability, type: :model do
  let(:user) { FactoryGirl.create :user }
  let(:event) { FactoryGirl.create :event }
  let(:deadline) { event.end_date }
  subject(:ability) { Ability.new(user, event) }

  shared_examples_for 'all users' do
    it 'can read public entities' do
      expect(ability).to be_able_to(:read, 'static_pages')
      expect(ability).to be_able_to(:manage, 'password_resets')
      expect(ability).to be_able_to(:read, Event)
      expect(ability).to be_able_to(:index, Event)
    end
  end

  context '- all users (guests)' do
    it_should_behave_like 'all users'
    it { expect(ability).to be_able_to(:manage, user) }

    it 'can view their attendances' do
      attendance = FactoryGirl.build(:attendance)
      expect(ability).not_to be_able_to(:show, attendance)
      attendance.email = user.email
      expect(ability).to be_able_to(:show, attendance)
      attendance.email = 'foo@bar.com'

      attendance.user = user
      expect(ability).to be_able_to(:show, attendance)
    end

    it 'can view their attendance even when other user created it' do
      other_user = FactoryGirl.build(:user)
      attendance = FactoryGirl.build(:attendance, user: other_user, email: user.email)
      expect(ability).to be_able_to(:show, attendance)
    end

    it 'can cancel (destroy) their attendances' do
      attendance = FactoryGirl.build(:attendance)
      expect(ability).not_to be_able_to(:destroy, attendance)
      attendance.user = user
      expect(ability).to be_able_to(:destroy, attendance)
    end

    it 'cannot confirm their attendances' do
      attendance = FactoryGirl.build(:attendance, user: user)
      expect(ability).not_to be_able_to(:confirm, attendance)
    end

    it 'cannot index all attendances' do
      expect(ability).not_to be_able_to(:index, Attendance)
    end

    describe 'can create a new attendance if:' do
      it '- before deadline' do
        Timecop.freeze(deadline - 1.day) do
          expect(ability).to be_able_to(:create, Attendance)
        end
      end

      it "- after deadline can't register" do
        Timecop.freeze(deadline + 1.second) do
          expect(ability).not_to be_able_to(:create, Attendance)
        end
      end
    end
  end

  context '- admin' do
    subject(:ability) { Ability.new(user, event) }
    before { user.add_role 'admin' }

    it { expect(ability).to be_able_to(:manage, :all) }
  end

  context 'as organizers' do
    context 'when the user manages the event' do
      let(:attendance) { FactoryGirl.create :attendance, event: event, user: user }
      before do
        user.organized_events << event
        user.add_role 'organizer'
        user.save!
      end
      subject(:ability) { Ability.new(user, event) }

      it_should_behave_like 'all users'
      context 'for event' do
        it { expect(ability).to be_able_to(:show, event) }
        it { expect(ability).to be_able_to(:edit, event) }
        it { expect(ability).to be_able_to(:update, event) }
        it { expect(ability).not_to be_able_to(:destroy, event) }
        it { expect(ability).not_to be_able_to(:create, event) }
      end
      context 'for attendance' do
        it { expect(ability).to be_able_to(:manage, attendance) }
      end
      context 'for registration_period' do
        let(:registration_period) { FactoryGirl.create :registration_period, event: event }
        it { expect(ability).to be_able_to(:manage, registration_period) }
      end
      context 'for registration_quota' do
        let(:registration_quota) { FactoryGirl.create :registration_quota, event: event }
        it { expect(ability).to be_able_to(:manage, registration_quota) }
      end
      context 'for registration_group' do
        let(:registration_group) { FactoryGirl.create :registration_group, event: event }
        it { expect(ability).to be_able_to(:manage, registration_group) }
      end
    end
  end
end
