# frozen_string_literal: true

RSpec.describe AttendancesController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to login_path }
    end
    describe 'POST #create' do
      before { post :create, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to login_path }
    end
    describe 'GET #edit' do
      before { get :edit, params: { event_id: 'foo', id: 'bar' } }
      it { expect(response).to redirect_to login_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { event_id: 'foo', id: 'bar' } }
      it { expect(response).to redirect_to login_path }
    end
    describe 'GET #search' do
      before { get :search, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to login_path }
    end
    describe 'PATCH #change_status' do
      before { put :update, params: { event_id: 'foo', id: 'bar', new_status: 'xpto' } }
      it { expect(response).to redirect_to login_path }
    end
  end

  context 'authenticated' do
    let(:user) { FactoryBot.create :organizer }
    let(:event) { FactoryBot.create :event, organizers: [user] }

    let(:valid_attendance) do
      {
        event_id: event.id,
        user_id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        organization: user.organization,
        organization_size: 'bla',
        job_role: :analyst,
        years_of_experience: '6',
        experience_in_agility: '9',
        school: 'school',
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

    let(:valid_event) { { name: 'Agile Brazil 2015', price_table_link: 'http://localhost:9292/link', full_price: 840.00, start_date: 1.month.from_now, end_date: 2.months.from_now, main_email_contact: 'contact@foo.com', attendance_limit: 1000 } }

    before { sign_in user }

    describe 'GET #new' do
      it 'renders new template' do
        get :new, params: { event_id: event }
        expect(response).to render_template :new
        expect(assigns(:attendance)).to be_a_new Attendance
        expect(assigns(:attendance).event).to eq event
      end
    end

    describe 'POST #create' do
      let(:email) { stub(deliver_now: true) }

      context 'valid parameters' do
        context 'easy attributes' do
          context 'and the event has vacancies' do
            context 'not an AA member' do
              context 'and it is a fresh new registration' do
                it 'creates the attendance and redirects to the show' do
                  EmailNotifications.expects(:registration_pending).returns(email)
                  post :create, params: { event_id: event, attendance: valid_attendance }
                  created_attendance = assigns(:attendance)
                  expect(created_attendance.event).to eq event
                  expect(created_attendance).to be_pending
                  expect(created_attendance.registration_group).to be_nil
                  expect(created_attendance.payment_type).to eq Invoice.last.payment_type
                  expect(created_attendance).to be_pending
                  expect(created_attendance.first_name).to eq user.first_name
                  expect(created_attendance.last_name).to eq user.last_name
                  expect(created_attendance.email).to eq user.email
                  expect(created_attendance.organization).to eq user.organization
                  expect(created_attendance.organization_size).to eq 'bla'
                  expect(created_attendance.job_role).to eq 'analyst'
                  expect(created_attendance.years_of_experience).to eq '6'
                  expect(created_attendance.experience_in_agility).to eq '9'
                  expect(created_attendance.school).to eq 'school'
                  expect(created_attendance.education_level).to eq 'level'
                  expect(created_attendance.phone).to eq user.phone
                  expect(created_attendance.country).to eq user.country
                  expect(created_attendance.state).to eq user.state
                  expect(created_attendance.city).to eq user.city
                  expect(created_attendance.badge_name).to eq user.badge_name
                  expect(created_attendance.cpf).to eq user.cpf
                  expect(created_attendance.gender).to eq user.gender
                  expect(response).to redirect_to event_attendance_path(event, created_attendance)
                  expect(flash[:notice]).to eq I18n.t('flash.attendance.create.success')
                end
              end
              context 'when attempt to register again' do
                context 'with a pending attendance existent' do
                  context 'in the same event' do
                    let!(:attendance) { FactoryBot.create(:attendance, event: event, user: user, status: :pending) }
                    it 'does not include the new attendance and send the user to show of attendance' do
                      AgileAllianceService.stubs(:check_member).returns(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 1
                      expect(response).to render_template :new
                      expect(assigns(:attendance).errors[:email]).to eq [I18n.t('flash.attendance.create.already_existent')]
                    end
                  end

                  context 'in other event' do
                    let(:other_event) { FactoryBot.create(:event) }
                    let!(:attendance) { FactoryBot.create(:attendance, event: other_event, user: user, status: :pending) }
                    it 'does not include the new attendance and send the user to show of attendance' do
                      AgileAllianceService.stubs(:check_member).returns(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 2
                    end
                  end
                end

                context 'with an accepted attendance existent' do
                  context 'in the same event' do
                    let!(:attendance) { FactoryBot.create(:attendance, event: event, user: user, status: :accepted) }
                    it 'does not include the new attendance and send the user to show of attendance' do
                      AgileAllianceService.stubs(:check_member).returns(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 1
                      expect(response).to render_template :new
                      expect(assigns(:attendance).errors[:email]).to eq [I18n.t('flash.attendance.create.already_existent')]
                    end
                  end

                  context 'in other event' do
                    let(:other_event) { FactoryBot.create(:event) }
                    let!(:attendance) { FactoryBot.create(:attendance, event: other_event, user: user, status: :accepted) }
                    it 'does not include the new attendance and send the user to show of attendance' do
                      AgileAllianceService.stubs(:check_member).returns(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 2
                    end
                  end
                end
                context 'with a paid attendance existent' do
                  context 'in the same event' do
                    let!(:attendance) { FactoryBot.create(:attendance, event: event, user: user, status: :paid) }
                    it 'does not add the attendance and re-render the form with the errors' do
                      AgileAllianceService.stubs(:check_member).returns(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 1
                      expect(response).to render_template :new
                      expect(assigns(:attendance).errors[:email]).to eq [I18n.t('flash.attendance.create.already_existent')]
                    end
                  end
                  context 'in other event' do
                    let(:other_event) { FactoryBot.create(:event) }
                    let!(:attendance) { FactoryBot.create(:attendance, event: other_event, user: user, status: :paid) }
                    it 'does not include the new attendance and send the user to show of attendance' do
                      AgileAllianceService.stubs(:check_member).returns(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 2
                    end
                  end
                end
                context 'with a confirmed attendance existent' do
                  context 'in the same event' do
                    let!(:attendance) { FactoryBot.create(:attendance, event: event, user: user, status: :confirmed) }
                    it 'does not include the new attendance and send the user to show of attendance' do
                      AgileAllianceService.stubs(:check_member).returns(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 1
                      expect(response).to render_template :new
                      expect(assigns(:attendance).errors[:email]).to eq [I18n.t('flash.attendance.create.already_existent')]
                    end
                  end
                  context 'in other event' do
                    let(:other_event) { FactoryBot.create(:event) }
                    let!(:attendance) { FactoryBot.create(:attendance, event: other_event, user: user, status: :confirmed) }
                    it 'does not include the new attendance and send the user to show of attendance' do
                      AgileAllianceService.stubs(:check_member).returns(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 2
                    end
                  end
                end
                context 'with a cancelled attendance existent' do
                  let!(:attendance) { FactoryBot.create(:attendance, event: event, user: user, status: :cancelled) }
                  it 'does not include the new attendance and send the user to show of attendance' do
                    AgileAllianceService.stubs(:check_member).returns(false)
                    post :create, params: { event_id: event, attendance: valid_attendance }
                    expect(Attendance.count).to eq 2
                  end
                end
              end
            end

            context 'an AA member' do
              before { stub_request(:post, 'http://cf.agilealliance.org/api/').to_return(status: 200, body: '<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><result>0</result></data>', headers: {}) }

              let!(:aa_group) { FactoryBot.create(:registration_group, event: event, name: 'Membros da Agile Alliance') }
              it 'uses the AA group as attendance group and accept the entrance' do
                Invoice.from_registration_group(aa_group, 'gateway')
                AgileAllianceService.stubs(:check_member).returns(true)
                RegistrationGroup.any_instance.stubs(:find_by).returns(aa_group)
                post :create, params: { event_id: event, attendance: valid_attendance }
                attendance = Attendance.last
                expect(attendance.registration_group).to eq aa_group
                expect(attendance).to be_accepted
              end
            end
          end

          context 'and the event has no vacancies' do
            context 'because it is full' do
              let(:other_user) { FactoryBot.create :user }
              let(:event) { FactoryBot.create :event, organizers: [user], attendance_limit: 1 }
              let!(:pending) { FactoryBot.create :attendance, event: event, status: :pending }
              subject(:attendance) { assigns(:attendance) }

              it 'puts the attendance in the queue' do
                EmailNotifications.expects(:registration_waiting).returns(email)
                post :create, params: { event_id: event, attendance: valid_attendance.merge(email: other_user.email) }
                expect(attendance.status).to eq 'waiting'
                expect(response).to redirect_to event_attendance_path(event, attendance)
                expect(flash[:notice]).to eq I18n.t('flash.attendance.create.success')
              end
            end

            context 'because it has attendances in the line' do
              let(:event) { FactoryBot.create :event, organizers: [user], attendance_limit: 10 }
              let!(:waiting) { FactoryBot.create :attendance, event: event, status: :waiting }
              subject(:attendance) { assigns(:attendance) }
              it 'puts the attendance in the queue' do
                EmailNotifications.expects(:registration_waiting).returns(email)
                post :create, params: { event_id: event, attendance: valid_attendance }
                expect(attendance.status).to eq 'waiting'
              end
            end
          end
        end

        context 'registration_value definition' do
          context 'having no period, quotas or groups' do
            before { post :create, params: { event_id: event, attendance: valid_attendance } }
            it { expect(assigns(:attendance).registration_value).to eq event.full_price }
          end
          context 'having no period or quotas, but with a valid group' do
            context 'and the group has vacancy' do
              context 'and it is not with automatic approval' do
                let(:group) { FactoryBot.create(:registration_group, event: event, discount: 30) }
                it 'defines the price using the group discount and keeps the registration pending' do
                  Invoice.from_registration_group(group, 'gateway')
                  post :create, params: { event_id: event, registration_token: group.token, attendance: valid_attendance }
                  expect(assigns(:attendance).registration_value).to eq event.full_price * 0.7
                  expect(assigns(:attendance)).to be_pending
                end
              end
              context 'when is an automatic approval group' do
                let!(:group) { FactoryBot.create(:registration_group, event: event, capacity: 20, automatic_approval: true) }
                it 'accepts the registration' do
                  Invoice.from_registration_group(group, 'gateway')
                  post :create, params: { event_id: event, registration_token: group.token, attendance: valid_attendance }
                  expect(assigns(:attendance)).to be_accepted
                end
              end
            end
            context 'and the group is full' do
              let!(:group) { FactoryBot.create(:registration_group, event: event, capacity: 2) }
              let!(:first_attendance) { FactoryBot.create(:attendance, event: event, registration_group: group) }
              let!(:second_attendance) { FactoryBot.create(:attendance, event: event, registration_group: group) }
              it 'render the form again with the error on flash' do
                post :create, params: { event_id: event, registration_token: group.token, attendance: valid_attendance }
                expect(response).to render_template :new
                expect(assigns(:attendance).errors[:registration_group]).to eq [I18n.t('attendances.create.errors.group_full')]
                expect(assigns(:attendance).registration_group).to eq group
              end
            end
          end
          context 'having period and no quotas or group' do
            let!(:full_registration_period) { FactoryBot.create(:registration_period, start_at: 2.days.ago, end_at: 1.day.from_now, event: event, price: 740) }
            it 'adds the period to the attendance and the correct price' do
              post :create, params: { event_id: event, attendance: valid_attendance }
              expect(assigns(:attendance).registration_period).to eq full_registration_period
              expect(assigns(:attendance).registration_value).to eq 740
            end
          end
          context 'having no period and one quota' do
            let!(:quota) { FactoryBot.create :registration_quota, event: event, quota: 40, order: 1, price: 350 }
            it 'adds the quota to the attendance and the correct price' do
              post :create, params: { event_id: event, attendance: valid_attendance }
              expect(assigns(:attendance).registration_quota).to eq quota
              expect(assigns(:attendance).registration_value).to eq 350
            end
          end
          context 'having statement_agreement as payment type, even with configured quotas and periods' do
            let!(:quota) { FactoryBot.create :registration_quota, event: event, quota: 40, order: 1, price: 350 }
            let!(:full_registration_period) { FactoryBot.create(:registration_period, start_at: 2.days.ago, end_at: 1.day.from_now, event: event, price: 740) }
            it 'uses the full event price as attendance value' do
              post :create, params: { event_id: event, payment_type: 'statement_agreement', attendance: valid_attendance }
              expect(Attendance.last.registration_value).to eq event.full_price
            end
          end
        end
      end

      context 'invalid' do
        context 'parameters' do
          it 'renders the template again with errors' do
            post :create, params: { event_id: event, attendance: { event_id: event } }
            expect(response).to render_template :new
            expect(assigns(:attendance).errors.full_messages).to eq ['Nome não pode ficar em branco', 'Sobrenome não pode ficar em branco', 'Email não pode ficar em branco', 'Email não é válido', 'Email é muito curto (mínimo: 6 caracteres)', 'Telefone não pode ficar em branco', 'País não pode ficar em branco', 'Cidade não pode ficar em branco', 'Estado não pode ficar em branco']
          end
        end
        context 'AA service response timeout' do
          let!(:aa_group) { FactoryBot.create(:registration_group, event: event, name: 'Membros da Agile Alliance') }
          context 'calling html' do
            it 'responds 408' do
              AgileAllianceService.stubs(:check_member).raises(Net::OpenTimeout)
              post :create, params: { event_id: event, attendance: valid_attendance }
              expect(response.status).to eq 408
            end
          end
          context 'calling JS' do
            it 'responds 408' do
              AgileAllianceService.stubs(:check_member).raises(Net::OpenTimeout)
              post :create, params: { event_id: event, attendance: valid_attendance }, xhr: true
              expect(response.status).to eq 408
            end
          end
        end
        context 'returning AWS error' do
          it 'calls the Airbrake' do
            CreateAttendance.stubs(:notify_attendance).raises(AWS::SES::ResponseError.new(stub(error: { code: 500, message: 'bla' })))
            Airbrake.expects(:notify).once
            post :create, params: { event_id: event, attendance: valid_attendance }
          end
        end
      end
    end

    describe 'GET #edit' do
      context 'with a valid attendance' do
        let(:event) { FactoryBot.create(:event, organizers: [user], full_price: 840.00) }
        let!(:group) { FactoryBot.create(:registration_group, event: event) }
        let!(:attendance) { FactoryBot.create(:attendance, event: event) }
        let!(:attendance_with_group) { FactoryBot.create(:attendance, event: event, registration_group: group) }

        it 'assigns the attendance and render edit' do
          get :edit, params: { event_id: event, id: attendance }
          expect(response).to render_template :edit
          expect(assigns(:attendance)).to eq attendance
        end
      end
    end

    describe 'PUT #update' do
      let(:event) { FactoryBot.create(:event, organizers: [user], full_price: 840.00) }
      let(:attendance) { FactoryBot.create(:attendance, event: event) }

      before do
        User.any_instance.stubs(:has_approved_session?).returns(true)
        sign_in user
        stub_request(:post, 'http://cf.agilealliance.org/api/').to_return(status: 200, body: '<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><result>0</result></data>', headers: {})
      end

      context 'with a valid attendance' do
        let!(:invoice) { Invoice.from_attendance(attendance, 'gateway') }
        context 'and no group token informed' do
          it 'updates the attendance' do
            put :update, params: { event_id: event, id: attendance, attendance: valid_attendance, payment_type: 'bank_deposit' }
            expect(Attendance.last.registration_group).to be_nil
            expect(Attendance.last.first_name).to eq user.first_name
            expect(Attendance.last.last_name).to eq user.last_name
            expect(Attendance.last.email).to eq user.email
            expect(Attendance.last.organization).to eq user.organization
            expect(Attendance.last.organization_size).to eq 'bla'
            expect(Attendance.last.analyst?).to be true
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
            expect(Attendance.last.invoices.last.payment_type).to eq 'bank_deposit'
            expect(response).to redirect_to event_attendances_path(event_id: event, flash: { notice: I18n.t('attendances.update.success') })
          end
        end

        context 'and with a group token informed' do
          context 'having space in the group' do
            let(:group) { FactoryBot.create(:registration_group, event: event, discount: 50) }

            it 'updates the user with the token' do
              put :update, params: { event_id: event, id: attendance, attendance: valid_attendance, payment_type: 'bank_deposit', registration_token: group.token }
              expect(Attendance.last.registration_group).to eq group
              expect(Attendance.last.registration_value).to eq 420
            end
          end
          context 'having no space in the group' do
            let!(:previous_attendance) { FactoryBot.create(:attendance, event: event) }
            let!(:group) { FactoryBot.create(:registration_group, event: event, capacity: 1, attendances: [previous_attendance]) }

            it 'updates the user with the token' do
              put :update, params: { event_id: event, id: attendance, attendance: valid_attendance, payment_type: 'bank_deposit', registration_token: group.token }
              expect(flash[:error]).to include I18n.t('attendances.create.errors.group_full')
            end
          end
        end

        context 'and the price band has changed' do
          let!(:quota) { FactoryBot.create(:registration_quota, event: event, quota: 1, price: 100) }
          let!(:attendance) { FactoryBot.create(:attendance, event: event, registration_quota: quota) }
          let!(:group) { FactoryBot.create(:registration_group, event: event, discount: 50) }

          context 'having the same group access token' do
            it 'updates the attendance and does not change the price' do
              put :update, params: { event_id: event, id: attendance, attendance: valid_attendance, payment_type: 'bank_deposit', registration_token: group.token }
              expect(Attendance.last.registration_group).to eq group
              expect(Attendance.last.registration_value).to eq 50
            end
          end
        end
      end
    end

    describe '#to_approval' do
      let(:event) { FactoryBot.create(:event, organizers: [user]) }
      let(:group) { FactoryBot.create(:registration_group, event: event) }
      let!(:pending) { FactoryBot.create(:attendance, event: event, registration_group: group, status: :pending) }
      let!(:other_pending) { FactoryBot.create(:attendance, event: event, registration_group: group, status: :pending) }
      let!(:out_pending) { FactoryBot.create(:attendance, event: event, status: :pending) }
      let!(:accepted) { FactoryBot.create(:attendance, event: event, registration_group: group, status: :accepted) }
      let!(:paid) { FactoryBot.create(:attendance, event: event, registration_group: group, status: :paid) }
      let!(:confirmed) { FactoryBot.create(:attendance, event: event, registration_group: group, status: :confirmed) }
      before { get :to_approval, params: { event_id: event } }
      it { expect(assigns(:attendances_to_approval)).to eq [pending, other_pending] }
    end

    describe '#waiting_list' do
      context 'signed as organizer' do
        let(:organizer) { FactoryBot.create :organizer }
        before { sign_in organizer }
        context 'and it is organizing the event' do
          let(:event) { FactoryBot.create(:event, organizers: [organizer]) }

          context 'having no attendances' do
            before { get :waiting_list, params: { event_id: event } }
            it { expect(response).to render_template :waiting_list }
            it { expect(assigns(:waiting_list)).to eq [] }
          end
          context 'having attendances' do
            let!(:waiting) { FactoryBot.create(:attendance, event: event, status: :waiting) }
            let!(:other_waiting) { FactoryBot.create(:attendance, event: event, status: :waiting) }
            let!(:out_waiting) { FactoryBot.create(:attendance, status: :waiting) }
            let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending) }
            let!(:accepted) { FactoryBot.create(:attendance, event: event, status: :accepted) }
            let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid) }
            let!(:confirmed) { FactoryBot.create(:attendance, event: event, status: :confirmed) }
            let!(:cancelled) { FactoryBot.create(:attendance, event: event, status: :cancelled) }

            it 'returns just the waiting attendances' do
              get :waiting_list, params: { event_id: event }
              expect(assigns(:waiting_list)).to match_array [waiting, other_waiting]
            end
          end
        end
        context 'and it does not organize the event' do
          let(:event) { FactoryBot.create(:event) }
          context 'having attendances' do
            let!(:waiting) { FactoryBot.create(:attendance, event: event, status: :waiting) }

            it 'redirects to root_path' do
              get :waiting_list, params: { event_id: event }
              expect(response).to redirect_to root_path
            end
          end
        end
      end

      context 'signed as admin' do
        let(:event) { FactoryBot.create(:event) }
        let(:admin) { FactoryBot.create :admin }
        before { sign_in admin }

        context 'with no attendances' do
          before { get :waiting_list, params: { event_id: event } }
          it { expect(response).to render_template :waiting_list }
          it { expect(assigns(:waiting_list)).to eq [] }
        end
        context 'with attendances' do
          let!(:waiting) { FactoryBot.create(:attendance, event: event, status: :waiting) }
          let!(:other_waiting) { FactoryBot.create(:attendance, event: event, status: :waiting) }
          let!(:out_waiting) { FactoryBot.create(:attendance, status: :waiting) }
          let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending) }
          let!(:accepted) { FactoryBot.create(:attendance, event: event, status: :accepted) }
          let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid) }
          let!(:confirmed) { FactoryBot.create(:attendance, event: event, status: :confirmed) }
          let!(:cancelled) { FactoryBot.create(:attendance, event: event, status: :cancelled) }

          it 'returns just the waiting attendances' do
            get :waiting_list, params: { event_id: event }
            expect(assigns(:waiting_list)).to match_array [waiting, other_waiting]
          end
        end
      end
    end

    describe 'GET #index' do
      before { travel_to Time.zone.local(2018, 2, 20, 10, 0, 0) }
      after { travel_back }

      context 'passing no search parameter' do
        context 'and no attendances' do
          let!(:event) { FactoryBot.create(:event, organizers: [user]) }
          before { get :index, params: { event_id: event, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', cancelled: 'cancelled' } }
          it { expect(assigns(:attendances_list)).to eq [] }
        end

        context 'and having attendances' do
          let!(:attendance) { FactoryBot.create(:attendance) }

          context 'and one attendance, but no association with event' do
            let!(:event) { FactoryBot.create(:event, organizers: [user]) }
            before { get :index, params: { event_id: event, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', cancelled: 'cancelled' } }
            it { expect(assigns(:attendances_list)).to eq [] }
          end
          context 'having attendances and reservations' do
            let(:event) { FactoryBot.create(:event, organizers: [user]) }
            let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending) }
            let!(:waiting) { FactoryBot.create(:attendance, event: event, status: :waiting) }
            let!(:accepted) { FactoryBot.create(:attendance, event: event, status: :accepted) }
            let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid) }
            let!(:confirmed) { FactoryBot.create(:attendance, event: event, status: :confirmed) }
            let!(:showed_in) { FactoryBot.create(:attendance, event: event, status: :showed_in) }
            let!(:cancelled) { FactoryBot.create(:attendance, event: event, status: :cancelled) }
            let!(:group) { FactoryBot.create :registration_group, event: event, paid_in_advance: true, capacity: 3, amount: 100 }

            before { get :index, params: { event_id: event, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', showed_in: 'showed_in', cancelled: 'cancelled' } }
            it 'assigns the instance variables and renders the template' do
              expect(response).to render_template :index
              expect(assigns(:attendances_list)).to match_array [pending, accepted, paid, confirmed, showed_in]
              expect(assigns(:waiting_total)).to eq 1
              expect(assigns(:pending_total)).to eq 1
              expect(assigns(:accepted_total)).to eq 1
              expect(assigns(:paid_total)).to eq 1
              expect(assigns(:reserved_total)).to eq 3
              expect(assigns(:accredited_total)).to eq 1
              expect(assigns(:cancelled_total)).to eq 1
              expect(assigns(:total)).to eq 8
              expect(assigns(:burnup_registrations_data).ideal.count).to eq 29
              expect(assigns(:burnup_registrations_data).actual.count).to eq 1
            end
          end
        end
      end
    end

    describe 'GET #show' do
      context 'with a valid attendance' do
        let!(:event) { FactoryBot.create(:event, organizers: [user]) }
        let!(:attendance) { FactoryBot.create(:attendance, event: event, user: user) }
        context 'having invoice' do
          let!(:invoice) { Invoice.from_attendance(attendance, 'gateway') }
          before { get :show, params: { event_id: event, id: attendance } }
          it { expect(assigns[:attendance]).to eq attendance }
          it { expect(response).to be_success }
        end

        context 'having no invoice' do
          before { get :show, params: { event_id: event, id: attendance } }
          it { expect(assigns[:attendance]).to eq attendance }
          it { expect(response).to be_success }
        end
      end
    end

    describe 'DELETE #destroy' do
      subject(:attendance) { FactoryBot.create(:attendance) }

      it 'cancels attendance' do
        Attendance.any_instance.expects(:cancel)
        delete :destroy, params: { event_id: event, id: attendance }
      end

      it 'not delete attendance' do
        Attendance.any_instance.expects(:destroy).never
        delete :destroy, params: { event_id: event, id: attendance }
      end

      it 'redirects back to status' do
        delete :destroy, params: { event_id: event, id: attendance }
        expect(response).to redirect_to(event_attendance_path(event, attendance))
      end

      context 'with invoice' do
        it 'cancel the attendance and the invoice' do
          Invoice.from_attendance(attendance, 'gateway')
          delete :destroy, params: { event_id: event, id: attendance }
          expect(Attendance.last.status).to eq 'cancelled'
          expect(Invoice.last.status).to eq 'cancelled'
        end
      end
    end

    describe 'PATCH #change_status' do
      let!(:event) { FactoryBot.create(:event, organizers: [user]) }

      context 'accept' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'pending') }
        it 'accepts attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'accept' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'accepted'
        end
      end
      context 'pay' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'pending') }
        it 'accepts attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'pay' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'confirmed'
        end
      end
      context 'confirm' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'pending') }
        it 'accepts attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'confirm' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'confirmed'
        end
      end
      context 'recover' do
        let(:invoice) { FactoryBot.create(:invoice, status: :cancelled) }
        let(:attendance) { FactoryBot.create(:attendance, event: event, invoices: [invoice], status: 'cancelled') }
        it 'accepts attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'recover' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(attendance.reload).to be_pending
          expect(invoice.reload).to be_pending
        end
      end
      context 'dequeue' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'waiting') }
        it 'accepts attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'dequeue' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'pending'
        end
      end
      context 'mark_show' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'confirmed') }
        it 'accepts attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'mark_show' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'showed_in'
        end
      end
    end

    describe 'GET #search' do
      let(:admin) { FactoryBot.create(:admin) }
      before { sign_in admin }

      context 'with search parameters, insensitive case' do
        let!(:event) { FactoryBot.create :event }
        context 'and no attendances' do
          before { get :search, params: { event_id: event, search: 'bla' }, xhr: true }
          it { expect(assigns(:attendances_list)).to eq [] }
        end

        context 'with attendances' do
          context 'and searching by first_name' do
            let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending, first_name: 'bLa') }
            let!(:accepted) { FactoryBot.create(:attendance, event: event, status: :accepted, first_name: 'bLaXPTO') }
            let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid, first_name: 'bLa') }
            let!(:confirmed) { FactoryBot.create(:attendance, event: event, status: :confirmed, first_name: 'bLa') }
            let!(:cancelled) { FactoryBot.create(:attendance, event: event, status: :cancelled, first_name: 'bLa') }

            let!(:out) { FactoryBot.create(:attendance, event: event, status: :pending, first_name: 'foO') }
            context 'including all statuses' do
              before { get :search, params: { event_id: event, search: 'bla', pending: 'true', accepted: 'true', paid: 'true', confirmed: 'true', cancelled: 'true' }, xhr: true }
              it { expect(assigns(:attendances_list)).to match_array [pending, accepted, paid, confirmed, cancelled] }
            end

            context 'without all statuses' do
              context 'without cancelled' do
                before { get :search, params: { event_id: event, search: 'bla', pending: 'true', accepted: 'true', paid: 'true' }, xhr: true }
                it { expect(assigns(:attendances_list)).to match_array [pending, accepted, paid, confirmed] }
              end
              context 'without cancelled, confirmed and paid' do
                before { get :search, params: { event_id: event, search: 'bla', pending: 'true', accepted: 'true' }, xhr: true }
                it { expect(assigns(:attendances_list)).to match_array [pending, accepted] }
              end
              context 'without cancelled, confirmed, paid and accepted' do
                before { get :search, params: { event_id: event, search: 'bla', pending: 'true' }, xhr: true }
                it { expect(assigns(:attendances_list)).to match_array [pending] }
              end
              context 'without statuses' do
                before { get :search, params: { event_id: event, search: 'bla' }, xhr: true }
                it { expect(assigns(:attendances_list)).to match_array [] }
              end
            end
          end

          context 'including all statuses' do
            let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending) }
            let!(:accepted) { FactoryBot.create(:attendance, event: event, status: :accepted) }
            let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid) }
            let!(:confirmed) { FactoryBot.create(:attendance, event: event, status: :confirmed) }
            let!(:cancelled) { FactoryBot.create(:attendance, event: event, status: :cancelled) }
            before { get :search, params: { event_id: event, pending: 'true', accepted: 'true', paid: 'true', confirmed: 'true', cancelled: 'true' }, xhr: true }
            it { expect(assigns(:attendances_list)).to match_array [pending, accepted, paid, confirmed, cancelled] }
          end

          context 'and searching by last_name' do
            let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending, last_name: 'bLa') }
            let!(:accepted) { FactoryBot.create(:attendance, event: event, status: :accepted, last_name: 'bLaXPTO') }
            let!(:out) { FactoryBot.create(:attendance, event: event, status: :pending, last_name: 'foO') }
            before { get :search, params: { event_id: event, pending: 'true', accepted: 'true', search: 'Bla' }, xhr: true }
            it { expect(assigns(:attendances_list)).to match_array [pending, accepted] }
          end

          context 'and searching by organization' do
            let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending, organization: 'sbbRUbles') }
            let!(:other_pending) { FactoryBot.create(:attendance, event: event, status: :pending, organization: 'sbbRUblesXPTO') }
            let!(:out) { FactoryBot.create(:attendance, event: event, status: :pending, organization: 'foO') }
            before { get :search, params: { event_id: event, pending: 'true', search: 'sbbrubles' }, xhr: true }
            it { expect(assigns(:attendances_list)).to match_array [pending, other_pending] }
          end

          context 'and searching by email' do
            let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending, email: 'bLa@xpto.com.br') }
            let!(:other_pending) { FactoryBot.create(:attendance, event: event, status: :pending, email: 'bLaSBBRUBLES@xpto.com.br') }
            let!(:out) { FactoryBot.create(:attendance, event: event, status: :pending, email: 'foO@xpto.com.br') }
            before { get :search, params: { event_id: event, pending: 'true', search: 'BLA' }, xhr: true }
            it { expect(assigns(:attendances_list)).to match_array [pending, other_pending] }
          end

          context 'and searching by ID' do
            let!(:pending) { FactoryBot.create(:attendance, event: event, first_name: 'bla', last_name: 'xpto', status: :pending, email: 'bLa@xpto.com.br') }
            let!(:out) { FactoryBot.create(:attendance, event: event, first_name: 'foo', last_name: 'bar', status: :pending, email: 'bLaSBBRUBLES@xpto.com.br') }
            before { get :search, params: { event_id: event, pending: 'true', search: pending.id }, xhr: true }
            it { expect(assigns(:attendances_list)).to eq [pending] }
          end
        end
      end

      context 'with csv format' do
        let!(:attendance) { FactoryBot.create(:attendance, event: event, status: :showed_in, first_name: 'bLa', updated_at: 1.day.ago) }
        let!(:other) { FactoryBot.create(:attendance, event: event, status: :showed_in, first_name: 'bLaXPTO') }
        let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending, first_name: 'bLaXPTO') }
        let!(:confirmed) { FactoryBot.create(:attendance, event: event, status: :confirmed, first_name: 'bLaXPTO') }
        let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid, first_name: 'bLaXPTO') }
        before { get :search, params: { event_id: event, paid: 'true', format: :csv } }
        it 'returns the attendances in the csv format' do
          expected_disposition = 'attachment; filename="attendances_list.csv"'
          expect(response.body).to eq AttendanceExportService.to_csv(event)
          expect(response.headers['Content-Disposition']).to eq expected_disposition
        end
      end
    end
  end
end
