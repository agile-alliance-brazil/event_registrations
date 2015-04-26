describe Attendance, type: :model do
  context 'associations' do
    it { should belong_to :event }
    it { should belong_to :user }
    it { should belong_to :registration_type }
    it { should belong_to :registration_quota }
    it { should have_many :invoices }
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

  context 'scopes' do
    context 'with five attendances created' do
      before { 5.times { FactoryGirl.create(:attendance) } }

      it 'should have scope for_event' do
        expect(Attendance.for_event(Attendance.first.event)).to eq([Attendance.first])
      end

      it 'should have scope for_registration_type' do
        rt = FactoryGirl.create(:registration_type, :event => Attendance.first.event)
        Attendance.first.tap{|a| a.registration_type = rt}.save

        expect(Attendance.for_registration_type(rt)).to eq([Attendance.first])
      end

      it 'should have scope without_registration_type' do
        rt = FactoryGirl.create(:registration_type, :event => Attendance.first.event)
        Attendance.first.tap{|a| a.registration_type = rt}.save

        expect(Attendance.without_registration_type(rt)).not_to include(Attendance.first)
      end

      it 'should have scope pending' do
        Attendance.first.tap(&:pay).save
        expect(Attendance.pending).not_to include(Attendance.first)
      end

      it 'should have scope paid' do
        Attendance.first.tap(&:pay).save
        expect(Attendance.paid).to eq([Attendance.first])
      end

      it 'should have scope active that excludes cancelled attendances' do
        Attendance.first.tap(&:cancel).save
        expect(Attendance.active).not_to include(Attendance.first)
      end

      it 'should have scope older_than that selects old attendances' do
        Attendance.first.tap{|a| a.registration_date = 10.days.ago}.save
        expect(Attendance.older_than(5.days.ago)).to eq([Attendance.first])
      end
    end

    context 'with specific seed' do
      describe '.search_for_list' do
        context 'and no attendances' do
          it { expect(Attendance.search_for_list('bla')).to eq [] }
        end

        context 'and having attendances' do
          let!(:attendance) { FactoryGirl.create(:attendance, first_name: 'xpto', last_name: 'bla', organization: 'foo', email: 'sbrubles@xpto.com', email_confirmation: 'sbrubles@xpto.com') }

          context 'active' do
            context 'and one active and other inactive' do
              let!(:other_attendance) { FactoryGirl.create(:attendance, status: 'cancelled') }
              it { expect(Attendance.search_for_list('xPTo')).to match_array [attendance] }
            end
          end

          context 'with one attendance' do
            context 'and matching fields' do
              context 'entire field' do
                it { expect(Attendance.search_for_list('xPTo')).to match_array [attendance] }
                it { expect(Attendance.search_for_list('bLa')).to match_array [attendance] }
                it { expect(Attendance.search_for_list('FoO')).to match_array [attendance] }
                it { expect(Attendance.search_for_list('sbRUblEs')).to match_array [attendance] }
              end

              context 'field part' do
                it { expect(Attendance.search_for_list('PT')).to match_array [attendance] }
                it { expect(Attendance.search_for_list('bL')).to match_array [attendance] }
                it { expect(Attendance.search_for_list('oO')).to match_array [attendance] }
                it { expect(Attendance.search_for_list('RUblEs')).to match_array [attendance] }
              end
            end
          end

          context 'with three attendances, one not matching' do
            let!(:other_attendance) { FactoryGirl.create(:attendance, first_name: 'bla', last_name: 'xpto', organization: 'sbrubles', email: 'foo@xpto.com', email_confirmation: 'foo@xpto.com') }
            let!(:out_attendance) { FactoryGirl.create(:attendance, first_name: 'Edsger', last_name: 'Dijkstra', organization: 'Turing', email: 'algorithm@node.path', email_confirmation: 'algorithm@node.path') }

            context 'entire field' do
              it { expect(Attendance.search_for_list('xPTo')).to match_array [attendance, other_attendance] }
              it { expect(Attendance.search_for_list('bLa')).to match_array [attendance, other_attendance] }
              it { expect(Attendance.search_for_list('FoO')).to match_array [attendance, other_attendance] }
              it { expect(Attendance.search_for_list('sbRUblEs')).to match_array [attendance, other_attendance] }
            end

            context 'field part' do
              it { expect(Attendance.search_for_list('PT')).to match_array [attendance, other_attendance] }
              it { expect(Attendance.search_for_list('bL')).to match_array [attendance, other_attendance] }
              it { expect(Attendance.search_for_list('oO')).to match_array [attendance, other_attendance] }
              it { expect(Attendance.search_for_list('RUblEs')).to match_array [attendance, other_attendance] }
            end
          end
        end
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

  describe '#discount' do
    let(:event) { Event.create!(name: Faker::Company.name, price_table_link: 'http://localhost:9292/link') }
    context 'when is not member of a group' do
      let(:individual) { RegistrationType.create!(title: 'registration_type.individual', event: event) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_type: individual) }
      it { expect(attendance.discount).to eq 1 }
    end

    context 'when is member of a 30% group' do
      let(:individual) { RegistrationType.create!(title: 'registration_type.individual', event: event) }
      let(:group) { FactoryGirl.create(:registration_group, event: event, discount: 30) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_type: individual, registration_group: group) }
      it { expect(attendance.discount).to eq 0.7 }
    end

    context 'when is member of a 100% group' do
      let(:individual) { RegistrationType.create!(title: 'registration_type.individual', event: event) }
      let(:group) { FactoryGirl.create(:registration_group, event: event, discount: 100) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_type: individual, registration_group: group) }
      it { expect(attendance.discount).to eq 0 }
    end
  end
end
