require 'webmock/rspec'

describe EventAttendancesController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:valid_attendance) do
    {
      event_id: @event.id,
      user_id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      organization: user.organization,
      organization_size: 'bla',
      job_role: 'role',
      years_of_experience: '6',
      experience_in_agility: '9',
      school: 'scholl',
      education_level: 'level',
      phone: user.phone,
      country: user.country,
      state: user.state,
      city: user.city,
      badge_name: user.badge_name,
      cpf: user.cpf,
      gender: user.gender
    }
  end
  let(:valid_event) do
    {
      name: 'Agile Brazil 2015', price_table_link: 'http://localhost:9292/link',
      full_price: 840.00, start_date: 1.month.from_now, end_date: 2.months.from_now,
      main_email_contact: 'contact@foo.com'
    }
  end

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
      is_expected.to render_template(:new)
    end

    it 'assigns current event to attendance' do
      get :new, event_id: @event.id
      expect(assigns(:attendance).event).to eq @event
    end
  end

  describe '#create' do
    context 'signed in' do
      let(:user) { FactoryGirl.create :user }
      before(:each) do
        sign_in user
        @email = stub(deliver_now: true)
        controller.current_user = user
        EmailNotifications.stubs(:registration_pending).returns(@email)
        Net::HTTP.stubs(:post).returns('<nil>')
        stub_request(:post, 'http://cf.agilealliance.org/api/').to_return(status: 200, body: '<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><result>0</result></data>', headers: {})
      end

      it 'renders new template when model is invalid' do
        post :create, event_id: @event.id, attendance: { event_id: @event.id }
        is_expected.to render_template(:new)
      end

      it 'redirects when model is valid' do
        post :create, event_id: @event.id, attendance: valid_attendance
        is_expected.to redirect_to attendance_path(Attendance.last, notice: I18n.t('flash.attendance.create.success'))
      end

      it 'assigns current event to attendance' do
        post :create, event_id: @event.id, attendance: valid_attendance
        expect(assigns(:attendance).event).to eq @event
        expect(assigns(:attendance).payment_type).to eq Invoice.last.payment_type
      end

      context 'event value for attendance' do
        before { Timecop.return }

        context 'when the AA service is returning timeout' do
          before { stub_request(:post, 'http://cf.agilealliance.org/api/').to_raise Net::OpenTimeout }
          context 'when the event has a group to AA discount' do
            let!(:aa_group) { FactoryGirl.create(:registration_group, event: @event, name: 'Membros da Agile Alliance') }
            context 'calling html' do
              it 'responds 408' do
                post :create, event_id: @event.id, attendance: valid_attendance
                expect(response.status).to eq 408
              end
            end
            context 'calling JS' do
              it 'responds 408' do
                xhr :post, :create, event_id: @event.id, attendance: valid_attendance
                expect(response.status).to eq 408
              end
            end
          end
          context 'when the event has no group to AA discount' do
            context 'calling html' do
              subject(:attendance) { assigns(:attendance) }
              it 'creates the attendance and redirects' do
                post :create, event_id: @event.id, attendance: valid_attendance
                expect(attendance).to be_persisted
                expect(response).to redirect_to attendance_path(attendance, notice: I18n.t('flash.attendance.create.success'))
              end
            end
          end
        end

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
          price = 740
          let(:event) { Event.create!(valid_event) }
          let!(:full_registration_period) { FactoryGirl.create(:registration_period, start_at: 2.days.ago, end_at: 1.day.from_now, event: event, price: price) }

          before { post :create, event_id: event.id, attendance: valid_attendance }
          it { expect(assigns(:attendance).registration_period).to eq full_registration_period }
          it { expect(assigns(:attendance).registration_value).to eq price }
        end

        context 'with no period and one quota' do
          price = 350
          let(:quota_event) { Event.create!(valid_event) }
          let!(:quota) { FactoryGirl.create :registration_quota, event: quota_event, quota: 40, order: 1, price: price }
          before { post :create, event_id: quota_event.id, attendance: valid_attendance }
          it { expect(assigns(:attendance).registration_quota).to eq quota }
          it { expect(assigns(:attendance).registration_value).to eq price }
        end

        context 'with statement_agreement as payment type, even with configured quotas and periods' do
          let(:event) { Event.create!(valid_event) }
          let!(:quota) { FactoryGirl.create :registration_quota, event: event, quota: 40, order: 1, price: 350 }
          let!(:full_registration_period) { FactoryGirl.create(:registration_period, start_at: 2.days.ago, end_at: 1.day.from_now, event: event, price: 740) }

          before { post :create, event_id: event.id, payment_type: Invoice::STATEMENT, attendance: valid_attendance }
          it { expect(Attendance.last.registration_value).to eq event.full_price }
        end
      end

      context 'for individual registration' do
        context 'full event' do
          let(:event) { FactoryGirl.create :event, attendance_limit: 1 }
          let!(:pending) { FactoryGirl.create :attendance, event: event, status: :pending }
          subject(:attendance) { assigns(:attendance) }

          it 'puts the attendance in the queue' do
            EmailNotifications.expects(:registration_waiting).returns @email
            post :create, event_id: event.id, attendance: valid_attendance
            expect(attendance.status).to eq 'waiting'
            is_expected.to redirect_to attendance_path(attendance, notice: I18n.t('flash.attendance.create.success'))
          end
        end
        context 'event having space, but also having attendances in the queue' do
          let(:event) { FactoryGirl.create :event, attendance_limit: 10 }
          let!(:waiting) { FactoryGirl.create :attendance, event: event, status: :waiting }
          subject(:attendance) { assigns(:attendance) }
          it 'puts the attendance in the queue' do
            EmailNotifications.expects(:registration_waiting).returns @email
            post :create, event_id: event, attendance: valid_attendance
            expect(attendance.status).to eq 'waiting'
            is_expected.to redirect_to attendance_path(attendance, notice: I18n.t('flash.attendance.create.success'))
          end
        end
        context 'with no token' do
          let!(:period) { RegistrationPeriod.create(event: @event, start_at: 1.month.ago, end_at: 1.month.from_now, price: 100) }
          subject(:attendance) { assigns(:attendance) }
          before { post :create, event_id: @event.id, attendance: valid_attendance }
          it 'creates the attendance and redirects' do
            expect(attendance.registration_group).to be_nil
            expect(attendance.first_name).to eq user.first_name
            expect(attendance.last_name).to eq user.last_name
            expect(attendance.status).to eq 'pending'
            expect(attendance.email).to eq user.email
            expect(attendance.organization).to eq user.organization
            expect(attendance.organization_size).to eq 'bla'
            expect(attendance.job_role).to eq 'role'
            expect(attendance.years_of_experience).to eq '6'
            expect(attendance.experience_in_agility).to eq '9'
            expect(attendance.education_level).to eq 'level'
            expect(attendance.phone).to eq user.phone
            expect(attendance.country).to eq user.country
            expect(attendance.state).to eq user.state
            expect(attendance.city).to eq user.city
            expect(attendance.badge_name).to eq user.badge_name
            expect(attendance.cpf).to eq user.cpf
            expect(attendance.gender).to eq user.gender
            is_expected.to redirect_to attendance_path(attendance, notice: I18n.t('flash.attendance.create.success'))
          end
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

        context 'when is an automatic approval group' do
          let!(:group) { FactoryGirl.create(:registration_group, event: @event, automatic_approval: true) }
          before do
            Invoice.from_registration_group(group, Invoice::GATEWAY)
            post :create, event_id: @event.id, registration_token: group.token, attendance: valid_attendance
          end
          it { expect(assigns(:attendance).status).to eq 'accepted' }
        end

        context 'when is not an automatic approval group' do
          let!(:group) { FactoryGirl.create(:registration_group, event: @event, automatic_approval: false) }
          before do
            Invoice.from_registration_group(group, Invoice::GATEWAY)
            post :create, event_id: @event.id, registration_token: group.token, attendance: valid_attendance
          end
          it { expect(assigns(:attendance).status).to eq 'pending' }
        end

        context 'when attempt to register again to the same event' do
          context 'with a pending attendance existent' do
            context 'in the same event' do
              let!(:attendance) { FactoryGirl.create(:attendance, event: @event, user: user, status: :pending) }
              it 'does not include the new attendance and send the user to show of attendance' do
                AgileAllianceService.stubs(:check_member).returns(false)
                post :create, event_id: @event.id, attendance: valid_attendance
                expect(Attendance.count).to eq 1
                is_expected.to render_template :new
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
                is_expected.to redirect_to attendance_path(Attendance.last, notice: I18n.t('flash.attendance.create.success'))
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
                is_expected.to render_template :new
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
                is_expected.to redirect_to attendance_path(Attendance.last, notice: I18n.t('flash.attendance.create.success'))
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
                is_expected.to render_template :new
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
                is_expected.to redirect_to attendance_path(Attendance.last, notice: I18n.t('flash.attendance.create.success'))
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
                is_expected.to render_template :new
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
                is_expected.to redirect_to attendance_path(Attendance.last, notice: I18n.t('flash.attendance.create.success'))
              end
            end
          end
          context 'with a cancelled attendance existent' do
            let!(:attendance) { FactoryGirl.create(:attendance, event: @event, user: user, status: :cancelled) }
            it 'does not include the new attendance and send the user to show of attendance' do
              AgileAllianceService.stubs(:check_member).returns(false)
              post :create, event_id: @event.id, attendance: valid_attendance
              expect(Attendance.count).to eq 2
              is_expected.to redirect_to attendance_path(Attendance.last, notice: I18n.t('flash.attendance.create.success'))
            end
          end
        end

        it 'sends pending registration e-mail' do
          Attendance.any_instance.stubs(:valid?).returns(true)
          EmailNotifications.expects(:registration_pending).returns(@email)
          post :create, event_id: @event.id, attendance: valid_attendance
        end
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
        is_expected.to render_template :edit
        expect(assigns(:attendance)).to eq attendance
      end

      it 'keeps group token and email confirmation' do
        get :edit, event_id: event.id, id: attendance_with_group.id
        expect(response.body).to have_field('registration_token', type: 'text', with: group.token)
      end
    end
  end

  describe '#update' do
    before do
      User.any_instance.stubs(:has_approved_session?).returns(true)
      sign_in user
      disable_authorization
      stub_request(:post, 'http://cf.agilealliance.org/api/').to_return(status: 200, body: '<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><result>0</result></data>', headers: {})
    end

    context 'with a valid attendance' do
      let(:event) { FactoryGirl.create(:event, full_price: 840.00) }
      let(:attendance) { FactoryGirl.create(:attendance, event: event) }
      let!(:invoice) { Invoice.from_attendance(attendance, Invoice::GATEWAY) }
      context 'and no group token informed' do
        it 'updates the attendance' do
          put :update, event_id: event.id, id: attendance.id, attendance: valid_attendance, payment_type: Invoice::DEPOSIT
          expect(Attendance.last.registration_group).to be_nil
          expect(Attendance.last.first_name).to eq user.first_name
          expect(Attendance.last.last_name).to eq user.last_name
          expect(Attendance.last.email).to eq user.email
          expect(Attendance.last.organization).to eq user.organization
          expect(Attendance.last.organization_size).to eq 'bla'
          expect(Attendance.last.job_role).to eq 'role'
          expect(Attendance.last.years_of_experience).to eq '6'
          expect(Attendance.last.experience_in_agility).to eq '9'
          expect(Attendance.last.education_level).to eq 'level'
          expect(Attendance.last.phone).to eq user.phone
          expect(Attendance.last.country).to eq user.country
          expect(Attendance.last.state).to eq user.state
          expect(Attendance.last.city).to eq user.city
          expect(Attendance.last.badge_name).to eq user.badge_name
          expect(Attendance.last.cpf).to eq user.cpf
          expect(Attendance.last.gender).to eq user.gender
          expect(Attendance.last.invoices.last.payment_type).to eq Invoice::DEPOSIT
          is_expected.to redirect_to attendances_path(event_id: event)
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
            organization: 'sbrubbles',
            phone: user.phone,
            country: user.country,
            state: user.state,
            city: user.city,
            badge_name: user.badge_name,
            cpf: user.cpf,
            gender: user.gender
          }
        end

        it 'assigns the attendance and render edit' do
          put :update, event_id: event.id, id: attendance.id, attendance: valid_attendance, payment_type: Invoice::DEPOSIT, registration_token: group.token
          expect(Attendance.last.email).to eq 'bla@foo.bar'
          expect(Attendance.last.organization).to eq 'sbrubbles'
          expect(Attendance.last.invoices.last.payment_type).to eq Invoice::DEPOSIT
          expect(Attendance.last.registration_group).to eq group
          expect(Attendance.last.registration_value).to eq 420
          is_expected.to redirect_to attendances_path(event_id: event)
        end
      end

      context 'and with a group token informed and the attendance is an AA member' do
        before do
          stub_request(:post, 'http://cf.agilealliance.org/api/').to_return(status: 200, body: '<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><result>1</result></data>', headers: {})
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
            organization: 'sbrubbles',
            phone: user.phone,
            country: user.country,
            state: user.state,
            city: user.city,
            badge_name: user.badge_name,
            cpf: user.cpf,
            gender: user.gender
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
          is_expected.to redirect_to attendances_path(event_id: event)
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
          it { expect(assigns(:attendances_state_grouped)).to eq('RJ' => 1) }
        end

        context 'with two attendances on same state' do
          let!(:other_carioca) { FactoryGirl.create(:attendance, event: event, state: 'RJ') }
          before { get :by_state, event_id: event.id }
          it { expect(assigns(:attendances_state_grouped)).to eq('RJ' => 2) }
        end

        context 'with two attendances in different states' do
          let!(:paulista_attendance) { FactoryGirl.create(:attendance, event: event, state: 'SP') }
          before { get :by_state, event_id: event.id }
          it { expect(assigns(:attendances_state_grouped)).to eq('RJ' => 1, 'SP' => 1) }
        end

        context 'with two attendances one active and other not' do
          let!(:paulista_attendance) { FactoryGirl.create(:attendance, event: event, state: 'SP', status: 'cancelled') }
          before { get :by_state, event_id: event.id }
          it { expect(assigns(:attendances_state_grouped)).to eq('RJ' => 1) }
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
          it { expect(assigns(:attendances_city_grouped)).to eq(['Rio de Janeiro', 'RJ'] => 1) }
        end

        context 'with two attendances on same state' do
          let!(:other_carioca) { FactoryGirl.create(:attendance, event: event, state: 'RJ', city: 'Rio de Janeiro') }
          before { get :by_city, event_id: event.id }
          it { expect(assigns(:attendances_city_grouped)).to eq(['Rio de Janeiro', 'RJ'] => 2) }
        end

        context 'with two attendances in different states' do
          let!(:paulista_attendance) { FactoryGirl.create(:attendance, event: event, state: 'SP', city: 'Sao Paulo') }
          before { get :by_city, event_id: event.id }
          it { expect(assigns(:attendances_city_grouped)).to eq(['Rio de Janeiro', 'RJ'] => 1, ['Sao Paulo', 'SP'] => 1) }
        end

        context 'with two attendances one active and other not' do
          let!(:paulista_attendance) { FactoryGirl.create(:attendance, event: event, state: 'SP', city: 'Sao Paulo', status: 'cancelled') }
          before { get :by_city, event_id: event.id }
          it { expect(assigns(:attendances_city_grouped)).to eq(['Rio de Janeiro', 'RJ'] => 1) }
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
          expect(assigns(:attendances_biweekly_grouped)).to eq(last_week.created_at.to_date => 2,
                                                               today.created_at.to_date => 1)
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
          expect(assigns(:payment_type_report)).to eq(['bank_deposit', 400] => 1,
                                                      ['gateway', 400] => 2,
                                                      ['statement_agreement', 400] => 1,
                                                      ['gateway', 123] => 1)
        end
      end
    end
  end

  describe '#waiting_list' do
    context 'signed as organizer' do
      let(:organizer) { FactoryGirl.create :organizer }
      before { sign_in organizer }
      context 'and it is organizing the event' do
        let(:event) { FactoryGirl.create(:event, organizers: [organizer]) }

        context 'having no attendances' do
          before { get :waiting_list, event_id: event.id }
          it { is_expected.to render_template :waiting_list }
          it { expect(assigns(:waiting_list)).to eq [] }
        end
        context 'having attendances' do
          let!(:waiting) { FactoryGirl.create(:attendance, event: event, status: :waiting) }
          let!(:other_waiting) { FactoryGirl.create(:attendance, event: event, status: :waiting) }
          let!(:out_waiting) { FactoryGirl.create(:attendance, status: :waiting) }
          let!(:pending) { FactoryGirl.create(:attendance, event: event, status: :pending) }
          let!(:accepted) { FactoryGirl.create(:attendance, event: event, status: :accepted) }
          let!(:paid) { FactoryGirl.create(:attendance, event: event, status: :paid) }
          let!(:confirmed) { FactoryGirl.create(:attendance, event: event, status: :confirmed) }
          let!(:cancelled) { FactoryGirl.create(:attendance, event: event, status: :cancelled) }

          it 'returns just the waiting attendances' do
            get :waiting_list, event_id: event.id
            expect(assigns(:waiting_list)).to match_array [waiting, other_waiting]
          end
        end
      end
      context 'and it does not organize the event' do
        let(:event) { FactoryGirl.create(:event) }
        context 'having attendances' do
          let!(:waiting) { FactoryGirl.create(:attendance, event: event, status: :waiting) }

          it 'redirects to root_path' do
            get :waiting_list, event_id: event.id
            is_expected.to redirect_to root_path
          end
        end
      end
    end

    context 'signed as admin' do
      let(:event) { FactoryGirl.create(:event) }
      let(:admin) { FactoryGirl.create :admin }
      before { sign_in admin }

      context 'with no attendances' do
        before { get :waiting_list, event_id: event.id }
        it { is_expected.to render_template :waiting_list }
        it { expect(assigns(:waiting_list)).to eq [] }
      end
      context 'with attendances' do
        let!(:waiting) { FactoryGirl.create(:attendance, event: event, status: :waiting) }
        let!(:other_waiting) { FactoryGirl.create(:attendance, event: event, status: :waiting) }
        let!(:out_waiting) { FactoryGirl.create(:attendance, status: :waiting) }
        let!(:pending) { FactoryGirl.create(:attendance, event: event, status: :pending) }
        let!(:accepted) { FactoryGirl.create(:attendance, event: event, status: :accepted) }
        let!(:paid) { FactoryGirl.create(:attendance, event: event, status: :paid) }
        let!(:confirmed) { FactoryGirl.create(:attendance, event: event, status: :confirmed) }
        let!(:cancelled) { FactoryGirl.create(:attendance, event: event, status: :cancelled) }

        it 'returns just the waiting attendances' do
          get :waiting_list, event_id: event.id
          expect(assigns(:waiting_list)).to match_array [waiting, other_waiting]
        end
      end
    end
  end
end
