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

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { event_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #user_info' do
      before { get :user_info, params: { event_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as user' do
    let(:user) { Fabricate :user, role: :user }
    let(:event) { Fabricate :event, organizers: [user] }

    before { sign_in user }

    describe 'GET #show' do
      context 'when the page required is for the logged user' do
        let!(:attendance) { Fabricate :attendance, user: user }

        before { get :show, params: { event_id: event, id: attendance } }

        it 'loads the page' do
          expect(response).to render_template :show
          expect(assigns(:attendance)).to eq attendance
        end
      end

      context 'when the page required is not for the logged user' do
        let!(:attendance) { Fabricate :attendance }

        before { get :show, params: { event_id: event, id: attendance } }

        it { expect(response).to have_http_status :not_found }
      end
    end

    describe 'GET #user_info' do
      before { get :user_info, params: { event_id: 'foo' } }

      it { expect(response).to have_http_status :not_found }
    end
  end

  context 'authenticated as organizer' do
    let(:user) { Fabricate :user, role: :organizer }
    let(:user_for_attendance) { Fabricate :user, role: :user }

    let(:event) { Fabricate :event, organizers: [user] }

    let(:valid_attendance) do
      {
        event_id: event.id,
        user_id: user_for_attendance.id,
        organization: 'foo',
        organization_size: 'micro_enterprises',
        job_role: :analyst,
        other_job_role: 'xpto bla',
        years_of_experience: 'less_than_five',
        experience_in_agility: 'less_than_two',
        country: user.country,
        state: user.state,
        city: user.city,
        badge_name: 'badge',
        source_of_interest: 'linkedin'
      }
    end

    let(:valid_event) { { name: 'Agile Brazil 2015', full_price: 840.00, start_date: 1.month.from_now, end_date: 2.months.from_now, main_email_contact: 'contact@foo.com', attendance_limit: 1000 } }

    before { sign_in user }

    describe 'GET #new' do
      context 'with running event' do
        it 'renders new template' do
          get :new, params: { event_id: event }
          expect(response).to render_template :new
          expect(assigns(:attendance)).to be_a_new Attendance
          expect(assigns(:attendance).event).to eq event
        end
      end

      context 'with past event' do
        let(:event) { Fabricate :event, organizers: [user], attendance_limit: 1, start_date: 3.hours.ago, end_date: 1.hour.ago }

        it 'puts the attendance in the queue' do
          get :new, params: { event_id: event }
          expect(response).to have_http_status :not_found
        end
      end
    end

    describe 'POST #create' do
      context 'valid parameters' do
        context 'easy attributes' do
          context 'and the event has vacancies' do
            context 'not an AA member' do
              context 'and it is a fresh new registration' do
                context 'and it is for the same user signed in' do
                  it 'creates the attendance and redirects to the show' do
                    Fabricate :slack_configuration, event: event

                    expect(EmailNotificationsMailer).to(receive(:registration_pending)).once.and_call_original
                    expect(Slack::SlackNotificationService.instance).to(receive(:notify_new_registration)).once

                    post :create, params: { event_id: event, attendance: valid_attendance }
                    created_attendance = assigns(:attendance)
                    expect(created_attendance.event).to eq event
                    expect(created_attendance.user).to eq user_for_attendance
                    expect(created_attendance.registered_by_user).to eq user
                    expect(created_attendance).to be_pending
                    expect(created_attendance.registration_group).to be_nil
                    expect(created_attendance.payment_type).to eq 'gateway'
                    expect(created_attendance).to be_pending
                    expect(created_attendance.organization).to eq 'foo'
                    expect(created_attendance.organization_size).to eq 'micro_enterprises'
                    expect(created_attendance.job_role).to eq 'analyst'
                    expect(created_attendance.other_job_role).to eq 'xpto bla'
                    expect(created_attendance.years_of_experience).to eq 'less_than_five'
                    expect(created_attendance.experience_in_agility).to eq 'less_than_two'
                    expect(created_attendance.country).to eq user.country
                    expect(created_attendance.state).to eq user.state
                    expect(created_attendance.city).to eq user.city
                    expect(created_attendance.badge_name).to eq 'badge'
                    expect(created_attendance.source_of_interest).to eq 'linkedin'
                    expect(response).to redirect_to event_attendance_path(event, created_attendance)
                    expect(flash[:notice]).to eq I18n.t('attendances.create.success')
                  end
                end
              end

              context 'and it is for a different user and it has no slack config' do
                it 'creates the attendance to the specified user' do
                  expect(EmailNotificationsMailer).to(receive(:registration_pending)).and_call_original
                  expect(Slack::SlackNotificationService.instance).not_to(receive(:notify_new_registration))

                  post :create, params: { event_id: event, attendance: valid_attendance }
                  created_attendance = assigns(:attendance)
                  expect(created_attendance.event).to eq event
                  expect(created_attendance.user).to eq user_for_attendance
                end
              end

              context 'when attempt to register again' do
                context 'with a pending attendance existent' do
                  context 'in the same event' do
                    let!(:attendance) { Fabricate(:attendance, event: event, user: user_for_attendance, status: :pending) }

                    it 'does not include the new attendance and send the user to show of attendance' do
                      allow(AgileAllianceService).to(receive(:check_member)).and_return(false)

                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 1
                      expect(response).to render_template :new
                      expect(flash[:alert]).to eq I18n.t('attendances.create.already_existent')
                    end
                  end

                  context 'in other event' do
                    let(:other_event) { Fabricate(:event) }
                    let!(:attendance) { Fabricate(:attendance, event: other_event, user: user_for_attendance, status: :pending) }

                    it 'does not include the new attendance and send the user to show of attendance' do
                      allow(AgileAllianceService).to(receive(:check_member)).and_return(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 2
                    end
                  end
                end

                context 'with an accepted attendance existent' do
                  context 'in the same event' do
                    let!(:attendance) { Fabricate(:attendance, event: event, user: user_for_attendance, status: :accepted) }

                    it 'does not include the new attendance and send the user to show of attendance' do
                      allow(AgileAllianceService).to(receive(:check_member)).and_return(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 1
                      expect(response).to render_template :new
                      expect(flash[:alert]).to eq I18n.t('attendances.create.already_existent')
                    end
                  end

                  context 'in other event' do
                    let(:other_event) { Fabricate(:event) }
                    let!(:attendance) { Fabricate(:attendance, event: other_event, user: user_for_attendance, status: :accepted) }

                    it 'does not include the new attendance and send the user to show of attendance' do
                      allow(AgileAllianceService).to(receive(:check_member)).and_return(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 2
                    end
                  end
                end

                context 'with a paid attendance existent' do
                  context 'in the same event' do
                    let!(:attendance) { Fabricate(:attendance, event: event, user: user_for_attendance, status: :paid) }

                    it 'does not add the attendance and re-render the form with the errors' do
                      allow(AgileAllianceService).to(receive(:check_member)).and_return(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }

                      expect(Attendance.count).to eq 1
                      expect(response).to render_template :new
                      expect(flash[:alert]).to eq I18n.t('attendances.create.already_existent')
                    end
                  end

                  context 'in other event' do
                    let(:other_event) { Fabricate(:event) }
                    let!(:attendance) { Fabricate(:attendance, event: other_event, user: user, status: :paid) }

                    it 'does not include the new attendance and send the user to show of attendance' do
                      allow(AgileAllianceService).to(receive(:check_member)).and_return(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 2
                    end
                  end
                end

                context 'with a confirmed attendance existent' do
                  context 'in the same event' do
                    let!(:attendance) { Fabricate(:attendance, event: event, user: user_for_attendance, status: :confirmed) }

                    it 'does not include the new attendance and send the user to show of attendance' do
                      allow(AgileAllianceService).to(receive(:check_member)).and_return(false)

                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 1
                      expect(response).to render_template :new
                      expect(flash[:alert]).to eq I18n.t('attendances.create.already_existent')
                    end
                  end

                  context 'in other event' do
                    let(:other_event) { Fabricate(:event) }
                    let!(:attendance) { Fabricate(:attendance, event: other_event, user: user, status: :confirmed) }

                    it 'does not include the new attendance and send the user to show of attendance' do
                      allow(AgileAllianceService).to(receive(:check_member)).and_return(false)
                      post :create, params: { event_id: event, attendance: valid_attendance }
                      expect(Attendance.count).to eq 2
                    end
                  end
                end

                context 'with an existent cancelled attendance' do
                  let!(:attendance) { Fabricate(:attendance, event: event, user: user, status: :cancelled) }

                  it 'does not include the new attendance and send the user to show of attendance' do
                    allow(AgileAllianceService).to(receive(:check_member)).and_return(false)
                    post :create, params: { event_id: event, attendance: valid_attendance }
                    expect(Attendance.count).to eq 2
                  end
                end
              end
            end

            context 'an AA member' do
              before { stub_request(:post, 'http://cf.agilealliance.org/api/').to_return(status: 200, body: '<?xml version=\"1.0\" encoding=\"UTF-8\"?><data><result>0</result></data>', headers: {}) }

              let!(:aa_group) { Fabricate(:registration_group, event: event, name: 'Membros da Agile Alliance') }

              it 'uses the AA group as attendance group and accept the entrance' do
                allow(AgileAllianceService).to(receive(:check_member)).and_return(true)
                allow(RegistrationGroup).to(receive(:find_by)).and_return(aa_group)

                post :create, params: { event_id: event, attendance: valid_attendance }
                attendance = Attendance.last
                expect(attendance.registration_group).to eq aa_group
                expect(attendance).to be_accepted
              end
            end
          end

          context 'and the event has no vacancies' do
            context 'because it is full' do
              subject(:attendance) { assigns(:attendance) }

              let(:other_user) { Fabricate :user }
              let(:event) { Fabricate :event, organizers: [user], attendance_limit: 1 }
              let!(:pending) { Fabricate :attendance, event: event, status: :pending }

              it 'puts the attendance in the queue' do
                expect(EmailNotificationsMailer).to(receive(:registration_waiting)).and_call_original
                post :create, params: { event_id: event, attendance: valid_attendance.merge(email: other_user.email) }
                expect(attendance.status).to eq 'waiting'
                expect(response).to redirect_to event_attendance_path(event, attendance)
                expect(flash[:notice]).to eq I18n.t('attendances.create.success')
              end
            end

            context 'because it has attendances in the line' do
              let(:event) { Fabricate :event, organizers: [user], attendance_limit: 10 }
              let!(:waiting) { Fabricate :attendance, event: event, status: :waiting }

              it 'puts the attendance in the queue' do
                expect(EmailNotificationsMailer).to(receive(:registration_waiting)).and_call_original
                post :create, params: { event_id: event, attendance: valid_attendance }

                expect(assigns(:attendance).status).to eq 'waiting'
              end
            end
          end

          context 'with past event' do
            let(:event) { Fabricate :event, organizers: [user], attendance_limit: 1, start_date: 3.hours.ago, end_date: 1.hour.ago }

            it 'puts the attendance in the queue' do
              post :create, params: { event_id: event, attendance: valid_attendance }
              expect(response).to have_http_status :not_found
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
                let(:group) { Fabricate(:registration_group, event: event, discount: 30) }

                it 'defines the price using the group discount and keeps the registration pending' do
                  post :create, params: { event_id: event, registration_token: group.token, attendance: valid_attendance }
                  expect(assigns(:attendance).registration_value).to eq event.full_price * 0.7
                  expect(assigns(:attendance)).to be_pending
                end
              end

              context 'when it is an automatic approval group' do
                let!(:group) { Fabricate(:registration_group, event: event, capacity: 20, automatic_approval: true) }

                it 'accepts the registration' do
                  post :create, params: { event_id: event, registration_token: group.token, attendance: valid_attendance }
                  expect(assigns(:attendance)).to be_accepted
                end
              end
            end
          end

          context 'having period and no quotas or group' do
            let!(:full_registration_period) { Fabricate(:registration_period, start_at: 2.days.ago, end_at: 1.day.from_now, event: event, price: 740) }

            it 'adds the period to the attendance and the correct price' do
              post :create, params: { event_id: event, attendance: valid_attendance }
              expect(assigns(:attendance).registration_period).to eq full_registration_period
              expect(assigns(:attendance).registration_value).to eq 740
            end
          end

          context 'having no period and one quota' do
            let!(:quota) { Fabricate :registration_quota, event: event, quota: 40, order: 1, price: 350 }

            it 'adds the quota to the attendance and the correct price' do
              post :create, params: { event_id: event, attendance: valid_attendance }
              expect(assigns(:attendance).registration_quota).to eq quota
              expect(assigns(:attendance).registration_value).to eq 350
            end
          end

          context 'having statement_agreement as payment type, even with configured quotas and periods' do
            let!(:quota) { Fabricate :registration_quota, event: event, quota: 40, order: 1, price: 350 }
            let!(:full_registration_period) { Fabricate(:registration_period, start_at: 2.days.ago, end_at: 1.day.from_now, event: event, price: 740) }

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
            expect(assigns(:attendance).errors.full_messages).to match_array ['País: não pode ficar em branco', 'Cidade: não pode ficar em branco', 'Estado: não pode ficar em branco']
            expect(flash[:error]).not_to be_blank
          end
        end

        context 'AA service response timeout' do
          let!(:aa_group) { Fabricate(:registration_group, event: event, name: 'Membros da Agile Alliance') }

          context 'calling html' do
            it 'responds 408' do
              allow(AgileAllianceService).to(receive(:check_member)).and_raise(Net::OpenTimeout)
              post :create, params: { event_id: event, attendance: valid_attendance }
              expect(response.status).to eq 408
            end
          end

          context 'calling JS' do
            it 'responds 408' do
              allow(AgileAllianceService).to(receive(:check_member)).and_raise(Net::OpenTimeout)
              post :create, params: { event_id: event, attendance: valid_attendance }, xhr: true
              expect(response.status).to eq 408
            end
          end
        end
      end
    end

    describe 'GET #edit' do
      context 'with a valid attendance' do
        let(:event) { Fabricate(:event, organizers: [user], full_price: 840.00) }
        let!(:group) { Fabricate(:registration_group, event: event) }
        let!(:attendance) { Fabricate(:attendance, event: event) }
        let!(:attendance_with_group) { Fabricate(:attendance, event: event, registration_group: group) }

        it 'assigns the attendance and render edit' do
          get :edit, params: { event_id: event, id: attendance }
          expect(response).to render_template :edit
          expect(assigns(:attendance)).to eq attendance
        end
      end
    end

    describe 'PUT #update' do
      let(:event) { Fabricate(:event, organizers: [user], full_price: 840.00) }
      let(:attendance) { Fabricate(:attendance, user: user_for_attendance, event: event, registration_value: 80) }
      let!(:aa_group) { Fabricate(:registration_group, event: event, name: 'Membros da Agile Alliance') }

      before { sign_in user }

      context 'with a valid attendance' do
        context 'and no group token informed' do
          it 'updates the attendance' do
            put :update, params: { event_id: event, id: attendance, attendance: valid_attendance, payment_type: 'bank_deposit' }
            updated_attendance = Attendance.last
            expect(updated_attendance.user).to eq user_for_attendance
            expect(updated_attendance.registration_group).to be_nil
            expect(updated_attendance.organization).to eq 'foo'
            expect(updated_attendance.organization_size).to eq 'micro_enterprises'
            expect(updated_attendance.job_role).to eq 'analyst'
            expect(updated_attendance.other_job_role).to eq 'xpto bla'
            expect(updated_attendance.years_of_experience).to eq 'less_than_five'
            expect(updated_attendance.experience_in_agility).to eq 'less_than_two'
            expect(updated_attendance.country).to eq user.country
            expect(updated_attendance.state).to eq user.state
            expect(updated_attendance.city).to eq user.city
            expect(updated_attendance.badge_name).to eq 'badge'
            expect(updated_attendance.payment_type).to eq 'bank_deposit'
            expect(updated_attendance.source_of_interest).to eq 'linkedin'
            expect(updated_attendance.registration_value).to eq 80
            expect(response).to redirect_to event_attendances_path(event_id: event, flash: { notice: I18n.t('attendances.update.success') })
          end
        end
      end

      context 'invalid' do
        let(:registration_group) { Fabricate :registration_group, event: event }

        context 'parameters' do
          it 'renders the template again with errors' do
            put :update, params: { event_id: event, id: attendance, attendance: { first_name: '', last_name: '', country: '', state: '', city: '', badge_name: '' } }
            expect(response).to render_template :edit
            expect(assigns(:attendance).errors.full_messages).to match_array ['País: não pode ficar em branco', 'Cidade: não pode ficar em branco', 'Estado: não pode ficar em branco']
            expect(flash[:error]).not_to be_blank
          end
        end
      end
    end

    describe 'GET #index' do
      before { travel_to Time.zone.local(2018, 2, 20, 10, 0, 0) }

      context 'passing no search parameter' do
        context 'and no attendances' do
          let!(:event) { Fabricate(:event, organizers: [user]) }

          before { get :index, params: { event_id: event, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', cancelled: 'cancelled' } }

          it { expect(assigns(:attendances_list)).to eq [] }
        end

        context 'and having attendances' do
          let!(:attendance) { Fabricate(:attendance) }

          context 'and one attendance, but no association with event' do
            let!(:event) { Fabricate(:event, organizers: [user]) }

            before { get :index, params: { event_id: event, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', cancelled: 'cancelled' } }

            it { expect(assigns(:attendances_list)).to eq [] }
          end

          context 'having attendances and reservations' do
            let(:event) { Fabricate(:event, organizers: [user]) }

            let!(:pending) { Fabricate(:attendance, event: event, status: :pending, updated_at: Time.zone.now) }
            let!(:waiting) { Fabricate(:attendance, event: event, status: :waiting, updated_at: 1.day.ago) }
            let!(:accepted) { Fabricate(:attendance, event: event, status: :accepted, updated_at: 2.days.ago) }
            let!(:paid) { Fabricate(:attendance, event: event, status: :paid, updated_at: 3.days.ago) }
            let!(:confirmed) { Fabricate(:attendance, event: event, status: :confirmed, updated_at: 4.days.ago) }
            let!(:showed_in) { Fabricate(:attendance, event: event, status: :showed_in, updated_at: 5.days.ago) }
            let!(:cancelled) { Fabricate(:attendance, event: event, status: :cancelled, updated_at: 6.days.ago) }

            let!(:group) { Fabricate :registration_group, event: event, paid_in_advance: true, capacity: 3, amount: 100 }

            it 'assigns the instance variables and renders the template' do
              get :index, params: { event_id: event, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', showed_in: 'showed_in', cancelled: 'cancelled' }

              expect(response).to render_template :index
              attendances_list = [pending, accepted, paid, confirmed, showed_in]
              expect(assigns(:attendances_list)).to eq attendances_list
              expect(assigns(:attendances_list_csv)).to eq AttendanceExportService.to_csv(attendances_list)

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
      let!(:event) { Fabricate(:event, organizers: [user]) }
      let!(:attendance) { Fabricate(:attendance, event: event) }

      before { get :show, params: { event_id: event, id: attendance } }

      it { expect(assigns[:attendance]).to eq attendance }
      it { expect(response).to be_successful }
    end

    describe 'DELETE #destroy' do
      subject(:attendance) { Fabricate(:attendance) }

      context 'when it is not ajax' do
        it 'redirects back to show' do
          expect_any_instance_of(Attendance).to(receive(:cancelled!))
          expect_any_instance_of(Attendance).not_to(receive(:destroy))

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
      let!(:event) { Fabricate(:event, organizers: [user]) }
      let(:group) { Fabricate(:registration_group, event: event) }

      context 'accept' do
        let(:attendance) { Fabricate(:attendance, event: event, registration_group: group, status: 'pending') }

        it 'accepts attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'accept' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'accepted'
        end
      end

      context 'pay' do
        let(:attendance) { Fabricate(:attendance, event: event, status: 'pending') }

        it 'pays the attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'pay' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'paid'
        end
      end

      context 'confirm' do
        let(:attendance) { Fabricate(:attendance, event: event, status: 'pending') }

        it 'confirms attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'confirm' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'confirmed'
        end
      end

      context 'recover' do
        let(:attendance) { Fabricate(:attendance, event: event, status: 'cancelled') }

        it 'recovers the attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'recover' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(attendance.reload).to be_pending
        end
      end

      context 'dequeue' do
        let(:attendance) { Fabricate(:attendance, event: event, status: 'waiting') }

        it 'dequeues attendance' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'dequeue' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'pending'
        end
      end

      context 'mark_show' do
        let(:attendance) { Fabricate(:attendance, event: event, status: 'confirmed') }

        it 'marks as showed' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'mark_show' }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'showed_in'
        end
      end

      context 'respond to html' do
        let(:attendance) { Fabricate(:attendance, event: event, status: 'confirmed') }

        it 'marks as showed and redirect to show page' do
          patch :change_status, params: { event_id: event, id: attendance, new_status: 'mark_show' }
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'showed_in'
          expect(response).to redirect_to event_attendance_path(event, attendance)
        end
      end
    end

    describe 'GET #search' do
      let(:admin) { Fabricate(:user, role: :admin) }

      before { sign_in admin }

      context 'with search parameters, insensitive case' do
        let!(:event) { Fabricate :event }

        context 'and no attendances' do
          before { get :search, params: { event_id: event, search: 'bla' }, xhr: true }

          it { expect(assigns(:attendances_list)).to eq [] }
        end

        context 'with attendances' do
          context 'and searching by first_name' do
            let(:pending_user) { Fabricate :user, first_name: 'bLa', last_name: 'aaa' }
            let(:accepted_user) { Fabricate :user, first_name: 'bLaXPTO', last_name: 'bbb' }
            let(:paid_user) { Fabricate :user, first_name: 'bLa', last_name: 'bbb' }
            let(:confirmed_user) { Fabricate :user, first_name: 'bLa', last_name: 'bbb' }
            let(:cancelled_user) { Fabricate :user, first_name: 'bLa', last_name: 'bbb' }
            let(:showed_user) { Fabricate :user, first_name: 'bLa', last_name: 'bbb' }

            let!(:pending) { Fabricate(:attendance, user: pending_user, event: event, status: :pending, updated_at: Time.zone.now) }
            let!(:accepted) { Fabricate(:attendance, user: accepted_user, event: event, status: :accepted, updated_at: 1.day.ago) }
            let!(:paid) { Fabricate(:attendance, user: paid_user, event: event, status: :paid, updated_at: 2.days.ago) }
            let!(:confirmed) { Fabricate(:attendance, user: confirmed_user, event: event, status: :confirmed, updated_at: 3.days.ago) }
            let!(:cancelled) { Fabricate(:attendance, user: cancelled_user, event: event, status: :cancelled, updated_at: 4.days.ago) }
            let!(:showed_in) { Fabricate(:attendance, user: showed_user, event: event, status: :showed_in, updated_at: 5.days.ago) }

            let!(:out) { Fabricate(:attendance, event: event, status: :pending) }

            context 'including all statuses' do
              it 'assigns the resuts and renders the template' do
                get :search, params: { event_id: event, search: 'bla', pending: 'true', accepted: 'true', paid: 'true', confirmed: 'true', cancelled: 'true' }, xhr: true

                expect(response).to render_template 'attendances/search'
                attendances_list = [pending, accepted, paid, confirmed, cancelled]
                expect(assigns(:attendances_list)).to match_array attendances_list
                expect(assigns(:attendances_list_csv)).to eq AttendanceExportService.to_csv(attendances_list)
              end
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

                it { expect(assigns(:attendances_list)).to eq [pending] }
              end

              context 'without statuses' do
                before { get :search, params: { event_id: event, search: 'bla' }, xhr: true }

                it { expect(assigns(:attendances_list)).to eq [] }
              end
            end
          end

          context 'including all statuses' do
            let!(:pending) { Fabricate(:attendance, event: event, status: :pending) }
            let!(:accepted) { Fabricate(:attendance, event: event, status: :accepted) }
            let!(:paid) { Fabricate(:attendance, event: event, status: :paid) }
            let!(:confirmed) { Fabricate(:attendance, event: event, status: :confirmed) }
            let!(:cancelled) { Fabricate(:attendance, event: event, status: :cancelled) }

            before { get :search, params: { event_id: event, pending: 'true', accepted: 'true', paid: 'true', confirmed: 'true', cancelled: 'true' }, xhr: true }

            it { expect(assigns(:attendances_list)).to match_array [pending, accepted, paid, confirmed, cancelled] }
          end

          context 'and searching by last_name' do
            let(:pending_user) { Fabricate :user, first_name: 'aaa', last_name: 'bLa' }
            let(:accepted_user) { Fabricate :user, first_name: 'bbb', last_name: 'bLaXPTO' }
            let!(:pending) { Fabricate(:attendance, user: pending_user, event: event, status: :pending) }
            let!(:accepted) { Fabricate(:attendance, user: accepted_user, event: event, status: :accepted) }

            let!(:other_attendance) { Fabricate(:attendance, event: event, status: :pending) }

            before { get :search, params: { event_id: event, pending: 'true', accepted: 'true', search: 'Bla' }, xhr: true }

            it { expect(assigns(:attendances_list)).to match_array [pending, accepted] }
          end

          context 'and searching by organization' do
            let!(:pending) { Fabricate(:attendance, event: event, status: :pending, organization: 'sbbRUbles') }
            let!(:other_pending) { Fabricate(:attendance, event: event, status: :pending, organization: 'sbbRUblesXPTO') }
            let!(:out) { Fabricate(:attendance, event: event, status: :pending, organization: 'foO') }

            before { get :search, params: { event_id: event, pending: 'true', search: 'sbbrubles' }, xhr: true }

            it { expect(assigns(:attendances_list)).to match_array [pending, other_pending] }
          end

          context 'and searching by email' do
            let(:pending_user) { Fabricate :user, first_name: 'aaa', last_name: 'bLa', email: 'bLa@xpto.com.br' }
            let(:other_pending_user) { Fabricate :user, first_name: 'bbb', last_name: 'bLaXPTO', email: 'bLaSBBRUBLES@xpto.com.br' }
            let(:out_user) { Fabricate :user, first_name: 'bbb', last_name: 'bLaXPTO', email: 'foO@bar.com.br' }

            let!(:pending) { Fabricate(:attendance, user: pending_user, event: event, status: :pending) }
            let!(:other_pending) { Fabricate(:attendance, user: other_pending_user, event: event, status: :pending) }
            let!(:out) { Fabricate(:attendance, user: out_user, event: event, status: :pending) }

            before { get :search, params: { event_id: event, pending: 'true', search: 'xpto.com' }, xhr: true }

            it { expect(assigns(:attendances_list)).to match_array [pending, other_pending] }
          end
        end
      end
    end

    describe 'GET #user_info' do
      context 'with valid attributes' do
        context 'and no user ID' do
          it 'assigns the instance variables and renders the template' do
            get :user_info, params: { event_id: event }, xhr: true
            expect(assigns(:attendance)).to be_a_new Attendance
            expect(assigns(:user)).to be_a_new User
            expect(response).to render_template 'attendances/user_info'
          end
        end

        context 'passing the user ID' do
          it 'assigns the instance variables and renders the template' do
            get :user_info, params: { event_id: event, user_id: user }, xhr: true
            expect(assigns(:attendance)).to be_a_new Attendance
            expect(assigns(:user)).to eq user
            expect(response).to render_template 'attendances/user_info'
          end
        end
      end

      context 'invalid' do
        context 'event' do
          context 'not found' do
            before { get :user_info, params: { event_id: 'foo' }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:event) { Fabricate :event }

            before { get :user_info, params: { event_id: event }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
