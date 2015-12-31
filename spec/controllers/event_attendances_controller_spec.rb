# encoding: UTF-8
require 'webmock/rspec'

describe EventAttendancesController, type: :controller do
  before :each do
    @event = FactoryGirl.create(:event)
    WebMock.enable!
  end

  after :each do
    WebMock.disable!
  end

  describe 'GET new' do
    before { controller.current_user = FactoryGirl.create(:user) }

    it 'renders new template' do
      get :new, event_id: @event.id
      expect(response).to render_template(:new)
    end

    it 'assigns current event to attendance' do
      get :new, event_id: @event.id
      expect(assigns(:attendance).event).to eq @event
    end
  end

  describe '#create' do
    let(:user) { FactoryGirl.create(:user) }
    let(:valid_attendance) do
      {
        event_id: @event.id,
        user_id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        email_confirmation: user.email,
        organization: user.organization,
        phone: user.phone,
        country: user.country,
        state: user.state,
        city: user.city,
        badge_name: user.badge_name,
        cpf: user.cpf,
        gender: user.gender,
        twitter_user: user.twitter_user,
        address: user.address,
        neighbourhood: user.neighbourhood,
        zipcode: user.zipcode
      }
    end
    let(:valid_event) do
      {
        name: 'Agile Brazil 2015', price_table_link: 'http://localhost:9292/link',
        full_price: 840.00, start_date: 1.month.from_now, end_date: 2.months.from_now
      }
    end
    before(:each) do
      @email = stub(deliver: true)
      controller.current_user = user
      EmailNotifications.stubs(:registration_pending).returns(@email)
      Net::HTTP.stubs(:post).returns('<nil>')
      stub_request(:post, 'http://cf.agilealliance.org/api/').to_return(:status => 200, :body => '<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><result>0</result></data>', :headers => {})
    end

    it 'renders new template when model is invalid' do
      user.phone = nil # User cannot have everything or we will just pick from there.
      # I think we need to consolidate all user and attendee information
      post :create, event_id: @event.id, attendance: { event_id: @event.id }
      expect(response).to render_template(:new)
    end

    it 'redirects when model is valid' do
      post :create, event_id: @event.id, attendance: valid_attendance
      expect(response).to redirect_to attendance_path(Attendance.last, notice: I18n.t('flash.attendance.create.success'))
    end

    it 'assigns current event to attendance' do
      post :create, event_id: @event.id, attendance: valid_attendance
      expect(assigns(:attendance).event).to eq @event
      expect(assigns(:attendance).payment_type).to eq Invoice.last.payment_type
    end

    context 'event value for attendance' do
      before { Timecop.return }

      context 'with no period, quotas or groups' do
        before { post :create, event_id: @event.id, attendance: valid_attendance }
        it { expect(assigns(:attendance).registration_value).to eq @event.full_price }
      end

      context 'with no period or quotas, but with a valid group' do
        let(:group) { FactoryGirl.create(:registration_group, event: @event, discount: 30) }
        before do
          Invoice.from_registration_group(group, Invoice::GATEWAY)
          post :create, event_id: @event.id, registration_token: group.token, attendance: valid_attendance
        end
        it { expect(assigns(:attendance).registration_value).to eq @event.full_price * 0.7 }
      end

      context 'with period and no quotas or group' do
        let(:event) { Event.create!(valid_event) }
        let!(:full_registration_period) { RegistrationPeriod.create!(start_at: 2.days.ago, end_at: 1.day.from_now, event: event, price: 740) }

        before { post :create, event_id: event.id, attendance: valid_attendance }
        it { expect(assigns(:attendance).registration_period).to eq full_registration_period }
        it { expect(assigns(:attendance).registration_value).to eq 740.00 }
      end

      context 'with no period and one quota' do
        let(:quota_event) { Event.create!(valid_event) }
        let!(:quota) { FactoryGirl.create :registration_quota, event: quota_event, quota: 40, order: 1, price: 350 }
        before { post :create, event_id: quota_event.id, attendance: valid_attendance }
        it { expect(assigns(:attendance).registration_quota).to eq quota }
        it { expect(assigns(:attendance).registration_value).to eq 350.00 }
      end

      context 'with statement_agreement as payment type, even with configured quotas and periods' do
        let(:event) { Event.create!(valid_event) }
        let!(:quota) { FactoryGirl.create :registration_quota, event: event, quota: 40, order: 1, price: 350 }
        let!(:full_registration_period) { RegistrationPeriod.create!(start_at: 2.days.ago, end_at: 1.day.from_now, event: event, price: 740) }

        before { post :create, event_id: event.id, payment_type: Invoice::STATEMENT, attendance: valid_attendance }
        it { expect(Attendance.last.registration_value).to eq event.full_price }
      end
    end

    it 'notifies airbrake if cannot send email' do
      Attendance.any_instance.stubs(:valid?).returns(true)
      exception = StandardError.new
      EmailNotifications.expects(:registration_pending).raises(exception)
      Airbrake.expects(:notify).with(exception)
      post :create, event_id: @event.id, attendance: valid_attendance
      expect(assigns(:attendance).event).to eq(@event)
    end

    it 'ignores airbrake errors if cannot send email' do
      Attendance.any_instance.stubs(:valid?).returns(true)
      exception = StandardError.new
      EmailNotifications.expects(:registration_pending).raises(exception)
      Airbrake.expects(:notify).with(exception).raises(exception)
      post :create, event_id: @event.id, attendance: valid_attendance
      expect(assigns(:attendance).event).to eq(@event)
    end

    context 'for individual registration' do
      context 'cannot add more attendances' do
        before { Event.any_instance.stubs(:can_add_attendance?).returns(false) }

        it 'redirects to home page with error message when cannot add more attendances' do
          post :create, event_id: @event.id, attendance: {}
          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq(I18n.t('flash.attendance.create.max_limit_reached'))
        end
      end

      context 'with no token' do
        let!(:period) { RegistrationPeriod.create(event: @event, start_at: 1.month.ago, end_at: 1.month.from_now, price: 100) }
        subject(:attendance) { assigns(:attendance) }
        before { post :create, event_id: @event.id, attendance: valid_attendance }
        it { expect(attendance.registration_group).to be_nil }
      end

      context 'with registration token' do
        let!(:period) { RegistrationPeriod.create(event: @event, start_at: 1.month.ago, end_at: 1.month.from_now, price: 100) }
        subject(:attendance) { assigns(:attendance) }

        context 'an invalid' do
          context 'and one event' do
            before { post :create, event_id: @event.id, registration_token: 'xpto', attendance: valid_attendance }
            it { expect(attendance.registration_group).to be_nil }
          end

          context 'and with a registration token from other event' do
            let(:other_event) { FactoryGirl.create :event }
            let!(:group) { FactoryGirl.create(:registration_group, event: @event) }
            let!(:other_group) { FactoryGirl.create(:registration_group, event: other_event) }
            before { post :create, event_id: @event.id, registration_token: other_group.token, attendance: valid_attendance }
            it { expect(attendance.registration_group).to be_nil }
          end
        end

        context 'a valid attendance' do
          context 'and same email as current user' do
            let!(:group) { FactoryGirl.create(:registration_group, event: @event) }
            before do
              Invoice.from_registration_group(group, Invoice::GATEWAY)
              post :create, event_id: @event.id, registration_token: group.token, attendance: valid_attendance
            end
            it { expect(attendance.registration_group).to eq group }
          end

          context 'and different email from current user' do
            let!(:group) { FactoryGirl.create(:registration_group, event: @event) }
            before do
              Invoice.from_registration_group(group, Invoice::GATEWAY)
              post :create, event_id: @event.id, registration_token: group.token, attendance: { email: 'warantesbr@gmail.com', email_confirmation: 'warantesbr@gmail.com' }
            end
            it { expect(attendance).to be_valid }
          end
        end
      end

      context 'when agile alliance member' do
        context 'and not in any group' do
          let!(:aa_group) { FactoryGirl.create(:registration_group, event: @event, name: 'Membros da Agile Alliance') }
          it 'uses the AA group as attendance group and accept the entrance' do
            Invoice.from_registration_group(aa_group, Invoice::GATEWAY)
            AgileAllianceService.stubs(:check_member).returns(true)
            RegistrationGroup.any_instance.stubs(:find_by).returns(aa_group)
            post :create, event_id: @event.id, attendance: valid_attendance
            attendance = Attendance.last
            expect(attendance.registration_group).to eq aa_group
          end
        end
      end

      context 'when attempt to register again to the same event' do
        context 'with a pending attendance existent' do
          context 'in the same event' do
            let!(:attendance) { FactoryGirl.create(:attendance, event: @event, user: user, status: :pending) }
            it 'does not include the new attendance and send the user to show of attendance' do
              AgileAllianceService.stubs(:check_member).returns(false)
              post :create, event_id: @event.id, attendance: valid_attendance
              expect(Attendance.count).to eq 1
              expect(response).to render_template :new
              expect(assigns(:attendance).errors[:email]).to eq [I18n.t('flash.attendance.create.already_existent')]
            end
          end

          context 'in other event' do
            let(:other_event) { FactoryGirl.create(:event) }
            let!(:attendance) { FactoryGirl.create(:attendance, event: other_event, user: user, status: :pending) }
            it 'does not include the new attendance and send the user to show of attendance' do
              AgileAllianceService.stubs(:check_member).returns(false)
              post :create, event_id: @event.id, attendance: valid_attendance
              expect(Attendance.count).to eq 2
              expect(response).to redirect_to attendance_path(Attendance.last, notice: I18n.t('flash.attendance.create.success'))
            end
          end
        end

        context 'with an accepted attendance existent' do
          context 'in the same event' do
            let!(:attendance) { FactoryGirl.create(:attendance, event: @event, user: user, status: :accepted) }
            it 'does not include the new attendance and send the user to show of attendance' do
              AgileAllianceService.stubs(:check_member).returns(false)
              post :create, event_id: @event.id, attendance: valid_attendance
              expect(Attendance.count).to eq 1
              expect(response).to render_template :new
              expect(assigns(:attendance).errors[:email]).to eq [I18n.t('flash.attendance.create.already_existent')]
            end
          end

          context 'in other event' do
            let(:other_event) { FactoryGirl.create(:event) }
            let!(:attendance) { FactoryGirl.create(:attendance, event: other_event, user: user, status: :accepted) }
            it 'does not include the new attendance and send the user to show of attendance' do
              AgileAllianceService.stubs(:check_member).returns(false)
              post :create, event_id: @event.id, attendance: valid_attendance
              expect(Attendance.count).to eq 2
              expect(response).to redirect_to attendance_path(Attendance.last, notice: I18n.t('flash.attendance.create.success'))
            end
          end
        end
        context 'with a paid attendance existent' do
          context 'in the same event' do
            let!(:attendance) { FactoryGirl.create(:attendance, event: @event, user: user, status: :paid) }
            it 'does not include the new attendance and send the user to show of attendance' do
              AgileAllianceService.stubs(:check_member).returns(false)
              post :create, event_id: @event.id, attendance: valid_attendance
              expect(Attendance.count).to eq 1
              expect(response).to render_template :new
              expect(assigns(:attendance).errors[:email]).to eq [I18n.t('flash.attendance.create.already_existent')]
            end
          end
          context 'in other event' do
            let(:other_event) { FactoryGirl.create(:event) }
            let!(:attendance) { FactoryGirl.create(:attendance, event: other_event, user: user, status: :paid) }
            it 'does not include the new attendance and send the user to show of attendance' do
              AgileAllianceService.stubs(:check_member).returns(false)
              post :create, event_id: @event.id, attendance: valid_attendance
              expect(Attendance.count).to eq 2
              expect(response).to redirect_to attendance_path(Attendance.last, notice: I18n.t('flash.attendance.create.success'))
            end
          end
        end
        context 'with a confirmed attendance existent' do
          context 'in the same event' do
            let!(:attendance) { FactoryGirl.create(:attendance, event: @event, user: user, status: :confirmed) }
            it 'does not include the new attendance and send the user to show of attendance' do
              AgileAllianceService.stubs(:check_member).returns(false)
              post :create, event_id: @event.id, attendance: valid_attendance
              expect(Attendance.count).to eq 1
              expect(response).to render_template :new
              expect(assigns(:attendance).errors[:email]).to eq [I18n.t('flash.attendance.create.already_existent')]
            end
          end
          context 'in other event' do
            let(:other_event) { FactoryGirl.create(:event) }
            let!(:attendance) { FactoryGirl.create(:attendance, event: other_event, user: user, status: :confirmed) }
            it 'does not include the new attendance and send the user to show of attendance' do
              AgileAllianceService.stubs(:check_member).returns(false)
              post :create, event_id: @event.id, attendance: valid_attendance
              expect(Attendance.count).to eq 2
              expect(response).to redirect_to attendance_path(Attendance.last, notice: I18n.t('flash.attendance.create.success'))
            end
          end
        end
        context 'with a cancelled attendance existent' do
          let!(:attendance) { FactoryGirl.create(:attendance, event: @event, user: user, status: :cancelled) }
          it 'does not include the new attendance and send the user to show of attendance' do
            AgileAllianceService.stubs(:check_member).returns(false)
            post :create, event_id: @event.id, attendance: valid_attendance
            expect(Attendance.count).to eq 2
            expect(response).to redirect_to attendance_path(Attendance.last, notice: I18n.t('flash.attendance.create.success'))
          end
        end
      end

      it 'should send pending registration e-mail' do
        Attendance.any_instance.stubs(:valid?).returns(true)
        EmailNotifications.expects(:registration_pending).returns(@email)
        post :create, event_id: @event.id, attendance: valid_attendance
      end
    end
  end

  describe '#edit' do
    before do
      User.any_instance.stubs(:has_approved_session?).returns(true)
      user = FactoryGirl.create(:user)
      sign_in user
      disable_authorization
    end

    context 'with a valid attendance' do
      let(:event) { FactoryGirl.create(:event, full_price: 840.00) }
      let!(:group) { FactoryGirl.create(:registration_group, event: @event) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event) }
      let!(:attendance_with_group) { FactoryGirl.create(:attendance, event: event, registration_group: group) }

      it 'assigns the attendance and render edit' do
        get :edit, event_id: event.id, id: attendance.id
        expect(response).to render_template :edit
        expect(assigns(:attendance)).to eq attendance
      end

      it 'keeps group token and email confirmation' do
        get :edit, event_id: event.id, id: attendance_with_group.id
        expect(response.body).to have_field('registration_token', type: 'text', with: group.token)
        expect(response.body).to have_field('attendance_email_confirmation', type: 'text', with: attendance_with_group.email_confirmation)
      end
    end
  end

  describe '#update' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      User.any_instance.stubs(:has_approved_session?).returns(true)
      sign_in user
      disable_authorization
      stub_request(:post, 'http://cf.agilealliance.org/api/').to_return(:status => 200, :body => '<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><result>0</result></data>', :headers => {})
    end

    context 'with a valid attendance' do
      let(:event) { FactoryGirl.create(:event, full_price: 840.00) }
      let(:attendance) { FactoryGirl.create(:attendance, event: event) }
      let!(:invoice) { Invoice.from_attendance(attendance, Invoice::GATEWAY) }
      context 'and no group token informed' do
        let(:valid_attendance) do
          {
            event_id: event.id,
            user_id: user.id,
            first_name: user.first_name,
            last_name: user.last_name,
            email: 'bla@foo.bar',
            email_confirmation: 'bla@foo.bar',
            organization: 'sbrubbles',
            phone: user.phone,
            country: user.country,
            state: user.state,
            city: user.city,
            badge_name: user.badge_name,
            cpf: user.cpf,
            gender: user.gender,
            twitter_user: user.twitter_user,
            address: user.address,
            neighbourhood: user.neighbourhood,
            zipcode: user.zipcode
          }
        end

        it 'assigns the attendance and render edit' do
          put :update, event_id: event.id, id: attendance.id, attendance: valid_attendance, payment_type: Invoice::DEPOSIT
          expect(Attendance.last.email).to eq 'bla@foo.bar'
          expect(Attendance.last.organization).to eq 'sbrubbles'
          expect(Attendance.last.invoices.last.payment_type).to eq Invoice::DEPOSIT
          expect(response).to redirect_to attendances_path(event_id: event)
        end
      end

      context 'and with a group token informed' do
        let(:group) { FactoryGirl.create(:registration_group, event: event, discount: 50) }
        let(:valid_attendance) do
          {
            event_id: event.id,
            user_id: user.id,
            first_name: user.first_name,
            last_name: user.last_name,
            email: 'bla@foo.bar',
            email_confirmation: 'bla@foo.bar',
            organization: 'sbrubbles',
            phone: user.phone,
            country: user.country,
            state: user.state,
            city: user.city,
            badge_name: user.badge_name,
            cpf: user.cpf,
            gender: user.gender,
            twitter_user: user.twitter_user,
            address: user.address,
            neighbourhood: user.neighbourhood,
            zipcode: user.zipcode
          }
        end

        it 'assigns the attendance and render edit' do
          put :update, event_id: event.id, id: attendance.id, attendance: valid_attendance, payment_type: Invoice::DEPOSIT, registration_token: group.token
          expect(Attendance.last.email).to eq 'bla@foo.bar'
          expect(Attendance.last.organization).to eq 'sbrubbles'
          expect(Attendance.last.invoices.last.payment_type).to eq Invoice::DEPOSIT
          expect(Attendance.last.registration_group).to eq group
          expect(Attendance.last.registration_value).to eq 420
          expect(response).to redirect_to attendances_path(event_id: event)
        end
      end

      context 'and with a group token informed and the attendance is an AA member' do
        before do
          stub_request(:post, 'http://cf.agilealliance.org/api/').to_return(:status => 200, :body => '<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><result>1</result></data>', :headers => {})
        end
        let!(:aa_group) { FactoryGirl.create(:registration_group, event: event, discount: 10) }
        let(:group) { FactoryGirl.create(:registration_group, event: event, discount: 50) }
        let(:valid_attendance) do
          {
            event_id: event.id,
            user_id: user.id,
            first_name: user.first_name,
            last_name: user.last_name,
            email: 'bla@foo.bar',
            email_confirmation: 'bla@foo.bar',
            organization: 'sbrubbles',
            phone: user.phone,
            country: user.country,
            state: user.state,
            city: user.city,
            badge_name: user.badge_name,
            cpf: user.cpf,
            gender: user.gender,
            twitter_user: user.twitter_user,
            address: user.address,
            neighbourhood: user.neighbourhood,
            zipcode: user.zipcode
          }
        end

        it 'assigns the attendance and render edit' do
          RegistrationGroup.stubs(:find_by).returns(aa_group)
          put :update, event_id: event.id, id: attendance.id, attendance: valid_attendance, payment_type: Invoice::DEPOSIT, registration_token: group.token
          expect(Attendance.last.email).to eq 'bla@foo.bar'
          expect(Attendance.last.organization).to eq 'sbrubbles'
          expect(Attendance.last.invoices.last.payment_type).to eq Invoice::DEPOSIT
          expect(Attendance.last.registration_group).to eq group
          expect(Attendance.last.registration_value).to eq 420
          expect(response).to redirect_to attendances_path(event_id: event)
        end
      end
    end
  end

  context 'reports' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      user.add_role :organizer
      user.save
      disable_authorization
      sign_in user
    end

    describe '#by_state' do
      let(:event) { FactoryGirl.create(:event) }

      context 'with no attendances' do
        before { get :by_state, event_id: event.id }
        it { expect(assigns(:attendances_state_grouped)).to eq({}) }
      end

      context 'with attendances' do
        let!(:carioca_attendance) { FactoryGirl.create(:attendance, event: event, state: 'RJ') }
        context 'with one attendance' do
          before { get :by_state, event_id: event.id }
          it { expect(assigns(:attendances_state_grouped)).to eq({ 'RJ' => 1 }) }
        end

        context 'with two attendances on same state' do
          let!(:other_carioca) { FactoryGirl.create(:attendance, event: event, state: 'RJ') }
          before { get :by_state, event_id: event.id }
          it { expect(assigns(:attendances_state_grouped)).to eq({ 'RJ' => 2 }) }
        end

        context 'with two attendances in different states' do
          let!(:paulista_attendance) { FactoryGirl.create(:attendance, event: event, state: 'SP') }
          before { get :by_state, event_id: event.id }
          it { expect(assigns(:attendances_state_grouped)).to eq({ 'RJ' => 1, 'SP' => 1 }) }
        end

        context 'with two attendances one active and other not' do
          let!(:paulista_attendance) { FactoryGirl.create(:attendance, event: event, state: 'SP', status: 'cancelled') }
          before { get :by_state, event_id: event.id }
          it { expect(assigns(:attendances_state_grouped)).to eq({ 'RJ' => 1 }) }
        end
      end
    end

    describe '#by_city' do
      let(:event) { FactoryGirl.create(:event) }

      context 'with no attendances' do
        before { get :by_city, event_id: event.id }
        it { expect(assigns(:attendances_city_grouped)).to eq({}) }
      end

      context 'with attendances' do
        let!(:carioca_attendance) { FactoryGirl.create(:attendance, event: event, state: 'RJ', city: 'Rio de Janeiro') }
        context 'with one attendance' do
          before { get :by_city, event_id: event.id }
          it { expect(assigns(:attendances_city_grouped)).to eq({ ['Rio de Janeiro', 'RJ'] => 1 }) }
        end

        context 'with two attendances on same state' do
          let!(:other_carioca) { FactoryGirl.create(:attendance, event: event, state: 'RJ', city: 'Rio de Janeiro') }
          before { get :by_city, event_id: event.id }
          it { expect(assigns(:attendances_city_grouped)).to eq({ ['Rio de Janeiro', 'RJ'] => 2 }) }
        end

        context 'with two attendances in different states' do
          let!(:paulista_attendance) { FactoryGirl.create(:attendance, event: event, state: 'SP', city: 'Sao Paulo') }
          before { get :by_city, event_id: event.id }
          it { expect(assigns(:attendances_city_grouped)).to eq({ ['Rio de Janeiro', 'RJ'] => 1, ['Sao Paulo', 'SP'] => 1 }) }
        end

        context 'with two attendances one active and other not' do
          let!(:paulista_attendance) { FactoryGirl.create(:attendance, event: event, state: 'SP', city: 'Sao Paulo', status: 'cancelled') }
          before { get :by_city, event_id: event.id }
          it { expect(assigns(:attendances_city_grouped)).to eq({ ['Rio de Janeiro', 'RJ'] => 1 }) }
        end
      end
    end

    describe '#last_biweekly_active' do
      let(:event) { FactoryGirl.create(:event) }

      context 'with no attendances' do
        before { get :last_biweekly_active, event_id: event.id }
        it { expect(assigns(:attendances_biweekly_grouped)).to eq({}) }
      end

      context 'with attendances' do
        it 'returns just the attendances within two weeks ago' do
          now = Time.zone.local(2015, 4, 30, 0, 0, 0)
          Timecop.freeze(now)
          last_week = FactoryGirl.create(:attendance, event: event, created_at: 7.days.ago)
          FactoryGirl.create(:attendance, event: event, created_at: 7.days.ago)
          today = FactoryGirl.create(:attendance, event: event)
          FactoryGirl.create(:attendance, event: event, created_at: 21.days.ago)
          FactoryGirl.create(:attendance)
          get :last_biweekly_active, event_id: event.id
          expect(assigns(:attendances_biweekly_grouped)).to eq({
                                                                 last_week.created_at.strftime('%Y-%m-%d') => 2,
                                                                 today.created_at.strftime('%Y-%m-%d') => 1
                                                               })
          Timecop.return
        end
      end
    end

    describe '#to_approval' do
      let(:event) { FactoryGirl.create(:event) }
      let(:group) { FactoryGirl.create(:registration_group, event: event) }
      let!(:pending) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: :pending) }
      let!(:other_pending) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: :pending) }
      let!(:out_pending) { FactoryGirl.create(:attendance, event: event, status: :pending) }
      let!(:accepted) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: :accepted) }
      let!(:paid) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: :paid) }
      let!(:confirmed) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: :confirmed) }
      before { get :to_approval, event_id: event.id }
      it { expect(assigns(:attendances_to_approval)).to eq [pending, other_pending] }
    end

    describe '#payment_type_report' do
      let(:event) { FactoryGirl.create(:event) }

      context 'with no attendances' do
        before { get :payment_type_report, event_id: event.id }
        it { expect(assigns(:payment_type_report)).to eq({}) }
      end

      context 'with attendances' do
        let!(:pending) { FactoryGirl.create(:attendance, event: event, status: :pending, payment_type: Invoice::GATEWAY) }
        let!(:paid) { FactoryGirl.create(:attendance, event: event, status: :paid, payment_type: Invoice::GATEWAY) }
        let!(:valued) { FactoryGirl.create(:attendance, event: event, status: :paid, payment_type: Invoice::GATEWAY, registration_value: 123) }
        let!(:grouped) { FactoryGirl.create(:attendance, event: event, status: :paid, payment_type: Invoice::GATEWAY) }
        let!(:confirmed) { FactoryGirl.create(:attendance, event: event, status: :confirmed, payment_type: Invoice::DEPOSIT) }
        let!(:other_confirmed) { FactoryGirl.create(:attendance, event: event, status: :confirmed, payment_type: Invoice::STATEMENT) }
        let!(:free) { FactoryGirl.create(:attendance, event: event, status: :confirmed, payment_type: Invoice::STATEMENT, registration_value: 0) }

        let!(:cancelled) { FactoryGirl.create(:attendance, event: event, status: :cancelled, payment_type: Invoice::GATEWAY) }
        let!(:out_of_event) { FactoryGirl.create(:attendance, status: :paid, payment_type: Invoice::GATEWAY) }

        before { get :payment_type_report, event_id: event.id }
        it 'returns the attendances with non free registration value grouped by payment type' do
          expect(assigns(:payment_type_report)).to eq({
                                                        ['bank_deposit', 400.0] => 1,
                                                        ['gateway', 400.0] => 2,
                                                        ['statement_agreement', 400.0] => 1,
                                                        ['gateway', 123.0] => 1
                                                      })
        end
      end
    end
  end
end
