# frozen_string_literal: true

RSpec.describe AttendancesController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #show' do
      before { get :show, params: { event_id: 'foo', id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #index' do
      before { get :index, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #edit' do
      before { get :edit, params: { event_id: 'foo', id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { event_id: 'foo', id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #search' do
      before { get :search, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PATCH #change_status' do
      before { patch :change_status, params: { event_id: 'foo', id: 'bar', new_status: 'xpto' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #attendance_past_info' do
      before { get :attendance_past_info, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'DELETE #destroy' do
      before { delete :destroy, params: { event_id: 'foo', id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as usere' do
    let(:user) { FactoryBot.create :user, role: :user }
    let(:event) { FactoryBot.create :event, organizers: [user] }

    before { sign_in user }

    describe 'GET #show' do
      context 'when the page required is for the logged user' do
        let!(:attendance) { FactoryBot.create :attendance, user: user }
        before { get :show, params: { event_id: event, id: attendance } }

        it 'loads the page' do
          expect(response).to render_template :show
          expect(assigns(:attendance)).to eq attendance
        end
      end
      context 'when the page required is not for the logged user' do
        let!(:attendance) { FactoryBot.create :attendance }
        before { get :show, params: { event_id: event, id: attendance } }

        it { expect(response).to have_http_status :not_found }
      end
    end
  end

  context 'authenticated as organizer' do
    let(:user) { FactoryBot.create :organizer }
    let(:user_for_attendance) { FactoryBot.create :user, role: :user }

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
      let(:email) { stub(deliver: true) }

      context 'valid parameters' do
        context 'easy attributes' do
          context 'and the event has vacancies' do
            context 'not an AA member' do
              context 'and it is a fresh new registration' do
                context 'and it is for the same user signed in' do
                  it 'creates the attendance and redirects to the show' do
                    EmailNotifications.expects(:registration_pending).returns(email)
                    post :create, params: { event_id: event, attendance: valid_attendance }
                    created_attendance = assigns(:attendance)
                    expect(created_attendance.event).to eq event
                    expect(created_attendance.user).to eq user
                    expect(created_attendance.registered_by_user).to eq user
                    expect(created_attendance).to be_pending
                    expect(created_attendance.registration_group).to be_nil
                    expect(created_attendance.payment_type).to eq 'gateway'
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
                    expect(flash[:notice]).to eq I18n.t('attendances.create.success')
                  end
                end
              end

              context 'and it is for a different user' do
                it 'creates the attendance to the specified user' do
                  EmailNotifications.expects(:registration_pending).returns(email)
                  post :create, params: { event_id: event, attendance: valid_attendance.merge(user_for_attendance: user_for_attendance) }
                  created_attendance = assigns(:attendance)
                  expect(created_attendance.event).to eq event
                  expect(created_attendance.user).to eq user_for_attendance
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
                      expect(assigns(:attendance).errors[:email]).to eq [I18n.t('attendances.create.already_existent')]
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
                      expect(assigns(:attendance).errors[:email]).to eq [I18n.t('attendances.create.already_existent')]
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
                      expect(assigns(:attendance).errors[:email]).to eq [I18n.t('attendances.create.already_existent')]
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
                      expect(assigns(:attendance).errors[:email]).to eq [I18n.t('attendances.create.already_existent')]
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
                context 'with an existent cancelled attendance' do
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
                expect(flash[:notice]).to eq I18n.t('attendances.create.success')
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
                  post :create, params: { event_id: event, registration_token: group.token, attendance: valid_attendance }
                  expect(assigns(:attendance).registration_value).to eq event.full_price * 0.7
                  expect(assigns(:attendance)).to be_pending
                end
              end
              context 'when it is an automatic approval group' do
                let!(:group) { FactoryBot.create(:registration_group, event: event, capacity: 20, automatic_approval: true) }
                it 'accepts the registration' do
                  post :create, params: { event_id: event, registration_token: group.token, attendance: valid_attendance }
                  expect(assigns(:attendance)).to be_accepted
                end
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

        pending 'and has a registration group and it has vacancies'
        pending 'and has a registration group and it has no vacancies'
      end

      context 'invalid' do
        context 'parameters' do
          it 'renders the template again with errors' do
            post :create, params: { event_id: event, attendance: { event_id: event } }
            expect(response).to render_template :new
            expect(assigns(:attendance).errors.full_messages).to eq ['Nome: não pode ficar em branco', 'Sobrenome: não pode ficar em branco', 'Email: não pode ficar em branco', 'Email: não é válido', 'Email: é muito curto (mínimo: 6 caracteres)', 'Telefone: não pode ficar em branco', 'País: não pode ficar em branco', 'Cidade: não pode ficar em branco', 'Estado: não pode ficar em branco']
            expect(flash[:error]).to eq 'Nome: não pode ficar em branco | Sobrenome: não pode ficar em branco | Email: não pode ficar em branco | Email: não é válido | Email: é muito curto (mínimo: 6 caracteres) | Telefone: não pode ficar em branco | País: não pode ficar em branco | Cidade: não pode ficar em branco | Estado: não pode ficar em branco'
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
      let!(:aa_group) { FactoryBot.create(:registration_group, event: event, name: 'Membros da Agile Alliance') }

      before do
        User.any_instance.stubs(:has_approved_session?).returns(true)
        sign_in user
      end

      context 'with a valid attendance' do
        context 'and no group token informed' do
          it 'updates the attendance' do
            AgileAllianceService.stubs(:check_member).returns(false)
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
            expect(Attendance.last.payment_type).to eq 'bank_deposit'
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

      context 'invalid' do
        let(:registration_group) { FactoryBot.create :registration_group, event: event }
        context 'parameters' do
          it 'renders the template again with errors' do
            AgileAllianceService.stubs(:check_member).returns(false)
            put :update, params: { event_id: event, id: attendance, attendance: { first_name: '', last_name: '', email: '', phone: '', country: '', state: '', city: '', badge_name: '', cpf: '', gender: '' } }
            expect(response).to render_template :edit
            expect(assigns(:attendance).errors.full_messages).to eq ['Nome: não pode ficar em branco', 'Sobrenome: não pode ficar em branco', 'Email: não pode ficar em branco', 'Email: não é válido', 'Email: é muito curto (mínimo: 6 caracteres)', 'Telefone: não pode ficar em branco', 'País: não pode ficar em branco', 'Cidade: não pode ficar em branco', 'Estado: não pode ficar em branco']
            expect(flash[:error]).to eq 'Nome: não pode ficar em branco | Sobrenome: não pode ficar em branco | Email: não pode ficar em branco | Email: não é válido | Email: é muito curto (mínimo: 6 caracteres) | Telefone: não pode ficar em branco | País: não pode ficar em branco | Cidade: não pode ficar em branco | Estado: não pode ficar em branco'
          end
        end
        context 'AA service response timeout' do
          context 'calling html' do
            it 'responds 408' do
              AgileAllianceService.stubs(:check_member).raises(Net::OpenTimeout)
              RegistrationGroup.any_instance.stubs(:find_by).returns(aa_group)
              put :update, params: { event_id: event, id: attendance, attendance: valid_attendance }
              expect(response.status).to eq 408
            end
          end
          context 'calling JS' do
            it 'responds 408' do
              AgileAllianceService.stubs(:check_member).raises(Net::OpenTimeout)
              RegistrationGroup.any_instance.stubs(:find_by).returns(aa_group)
              put :update, params: { event_id: event, id: attendance, attendance: valid_attendance }, xhr: true
              expect(response.status).to eq 408
            end
          end
        end
      end
    end

    describe 'GET #to_approval' do
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

    describe 'GET #waiting_list' do
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
            before { get :waiting_list, params: { event_id: event } }
            it { expect(response).to have_http_status :not_found }
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
              expect(assigns(:confirmed_total)).to eq 1
              expect(assigns(:reserved_total)).to eq 3
              expect(assigns(:accredited_total)).to eq 1
              expect(assigns(:cancelled_total)).to eq 1
              expect(assigns(:total)).to eq 8
            end
          end
        end
      end
    end

    describe 'GET #show' do
      let!(:event) { FactoryBot.create(:event, organizers: [user]) }
      let!(:attendance) { FactoryBot.create(:attendance, event: event) }
      before { get :show, params: { event_id: event, id: attendance } }
      it { expect(assigns[:attendance]).to eq attendance }
      it { expect(response).to be_successful }
    end

    describe 'DELETE #destroy' do
      subject(:attendance) { FactoryBot.create(:attendance) }

      context 'when it is not ajax' do
        it 'redirects back to show' do
          Attendance.any_instance.expects(:cancelled!)
          Attendance.any_instance.expects(:destroy).never

          delete :destroy, params: { event_id: event, id: attendance }
          expect(response).to redirect_to(event_attendance_path(event, attendance))
        end
      end
      context 'when it is ajax' do
        it 'redirects back to show' do
          delete :destroy, params: { event_id: event, id: attendance }, xhr: true
          expect(response).to render_template 'attendances/attendance'
        end
      end
    end

    describe 'PATCH #change_status' do
      let!(:event) { FactoryBot.create(:event, organizers: [user]) }
      let(:group) { FactoryBot.create(:registration_group, event: event) }

      context 'accept' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, registration_group: group, status: 'pending') }
        it 'accepts attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'accept' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'accepted'
        end
      end
      context 'pay' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'pending') }
        it 'pays the attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'pay' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'paid'
        end
      end
      context 'confirm' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'pending') }
        it 'confirms attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'confirm' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'confirmed'
        end
      end
      context 'recover' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'cancelled') }
        it 'recovers the attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'recover' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(attendance.reload).to be_pending
        end
      end
      context 'dequeue' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'waiting') }
        it 'dequeues attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'dequeue' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'pending'
        end
      end
      context 'mark_show' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'confirmed') }
        it 'marks as showed' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'mark_show' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'showed_in'
        end
      end
      context 'respond to html' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'confirmed') }
        it 'marks as showed and redirect to show page' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'mark_show' }
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'showed_in'
          expect(response).to redirect_to event_attendance_path(event, attendance)
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
            let!(:showed_in) { FactoryBot.create(:attendance, event: event, status: :showed_in, first_name: 'bLa') }

            let!(:out) { FactoryBot.create(:attendance, event: event, status: :pending, first_name: 'foO') }
            context 'including all statuses' do
              before { get :search, params: { event_id: event, search: 'bla', pending: 'true', accepted: 'true', paid: 'true', confirmed: 'true', cancelled: 'true' }, xhr: true }
              it { expect(assigns(:attendances_list)).to match_array [pending, accepted, paid, confirmed, cancelled] }
            end

            context 'some statuses' do
              context 'without cancelled' do
                before { get :search, params: { event_id: event, search: 'bla', pending: 'true', accepted: 'true', paid: 'true', confirmed: 'true' }, xhr: true }
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

    describe 'GET #attendance_past_info' do
      context 'valid parameters' do
        context 'when there is another attendance to the user' do
          let(:event) { FactoryBot.create :event }
          let!(:attendance) { FactoryBot.create :attendance, event: event, user: user, created_at: 1.day.ago }
          let!(:other_attendance) { FactoryBot.create :attendance, user: user, email: attendance.email, created_at: Time.zone.now }

          it 'assigns a clone of the last attendance to the form' do
            get :attendance_past_info, params: { event_id: event, email: attendance.email }, xhr: true
            expect(response).to render_template 'attendances/attendance_info'
            expect(assigns(:attendance).id).to be_nil
            expect(assigns(:attendance).registration_group).to eq other_attendance.registration_group
            expect(assigns(:attendance).first_name).to eq other_attendance.first_name
            expect(assigns(:attendance).last_name).to eq other_attendance.last_name
            expect(assigns(:attendance).email).to eq other_attendance.email
            expect(assigns(:attendance).organization).to eq other_attendance.organization
            expect(assigns(:attendance).organization_size).to eq other_attendance.organization_size
            expect(assigns(:attendance).job_role).to eq other_attendance.job_role
            expect(assigns(:attendance).years_of_experience).to eq other_attendance.years_of_experience
            expect(assigns(:attendance).experience_in_agility).to eq other_attendance.experience_in_agility
            expect(assigns(:attendance).education_level).to eq other_attendance.education_level
            expect(assigns(:attendance).phone).to eq other_attendance.phone
            expect(assigns(:attendance).country).to eq other_attendance.country
            expect(assigns(:attendance).state).to eq other_attendance.state
            expect(assigns(:attendance).city).to eq other_attendance.city
            expect(assigns(:attendance).badge_name).to eq other_attendance.badge_name
            expect(assigns(:attendance).cpf).to eq other_attendance.cpf
            expect(assigns(:attendance).gender).to eq other_attendance.gender
            expect(assigns(:attendance).payment_type).to eq other_attendance.payment_type
          end
        end
        context 'when there is no another attendance to the user' do
          let(:event) { FactoryBot.create :event }

          it 'assigns a clone of the last attendance to the form' do
            get :attendance_past_info, params: { event_id: event, email: 'foo@bar.com' }, xhr: true
            expect(response).to render_template 'attendances/attendance_info'
            expect(assigns(:attendance).registration_group).to be_nil
            expect(assigns(:attendance).first_name).to be_nil
            expect(assigns(:attendance).last_name).to be_nil
            expect(assigns(:attendance).email).to eq 'foo@bar.com'
            expect(assigns(:attendance).organization).to be_nil
            expect(assigns(:attendance).organization_size).to be_nil
            expect(assigns(:attendance).job_role).to eq 'not_informed'
            expect(assigns(:attendance).years_of_experience).to be_nil
            expect(assigns(:attendance).experience_in_agility).to be_nil
            expect(assigns(:attendance).education_level).to be_nil
            expect(assigns(:attendance).phone).to be_nil
            expect(assigns(:attendance).country).to be_nil
            expect(assigns(:attendance).state).to be_nil
            expect(assigns(:attendance).city).to be_nil
            expect(assigns(:attendance).badge_name).to be_nil
            expect(assigns(:attendance).cpf).to be_nil
            expect(assigns(:attendance).gender).to be_nil
            expect(assigns(:attendance).payment_type).to be_nil
          end
          context 'when the email in params is blank' do
            let(:event) { FactoryBot.create :event }

            it 'assigns a clone of the last attendance to the form' do
              Attendance.expects(:where).never
              get :attendance_past_info, params: { event_id: event, email: '' }, xhr: true
              expect(response).to render_template 'attendances/attendance_info'
              expect(assigns(:attendance).registration_group).to be_nil
              expect(assigns(:attendance).first_name).to be_nil
              expect(assigns(:attendance).last_name).to be_nil
              expect(assigns(:attendance).email).to eq ''
              expect(assigns(:attendance).organization).to be_nil
              expect(assigns(:attendance).organization_size).to be_nil
              expect(assigns(:attendance).job_role).to eq 'not_informed'
              expect(assigns(:attendance).years_of_experience).to be_nil
              expect(assigns(:attendance).experience_in_agility).to be_nil
              expect(assigns(:attendance).education_level).to be_nil
              expect(assigns(:attendance).phone).to be_nil
              expect(assigns(:attendance).country).to be_nil
              expect(assigns(:attendance).state).to be_nil
              expect(assigns(:attendance).city).to be_nil
              expect(assigns(:attendance).badge_name).to be_nil
              expect(assigns(:attendance).cpf).to be_nil
              expect(assigns(:attendance).gender).to be_nil
              expect(assigns(:attendance).payment_type).to be_nil
            end
          end
        end
      end
      context 'invalid' do
        context 'event' do
          before { get :attendance_past_info, params: { event_id: 'foo', email: 'bar' }, xhr: true }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
