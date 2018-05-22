# frozen_string_literal: true

RSpec.describe ReportsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #attendance_organization_size' do
      before { get :attendance_organization_size, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to login_path }
    end
    describe 'GET #attendance_years_of_experience' do
      before { get :attendance_years_of_experience, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to login_path }
    end
    describe 'GET #attendance_job_role' do
      before { get :attendance_years_of_experience, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to login_path }
    end
    describe 'GET #burnup_registrations' do
      before { get :attendance_years_of_experience, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to login_path }
    end
    describe 'GET #by_state' do
      before { get :by_state, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to login_path }
    end
    describe 'GET #by_city' do
      before { get :by_city, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to login_path }
    end
    describe 'GET #last_biweekly_active' do
      before { get :last_biweekly_active, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to login_path }
    end
    describe 'GET #payment_type_report' do
      before { get :payment_type_report, params: { event_id: 'foo' } }
      it { expect(response).to redirect_to login_path }
    end
  end

  context 'authenticated as organizer' do
    let(:user) { FactoryBot.create :user, roles: [:organizer] }
    before { sign_in user }

    context 'and is organizing the event' do
      describe 'GET #attendance_organization_size' do
        let(:event) { FactoryBot.create :event }
        let!(:attendances) { FactoryBot.create_list(:attendance, 10, event: event) }
        let!(:no_company_attendances) { FactoryBot.create_list(:attendance, 2, event: event, organization_size: nil) }
        let!(:cancelled_attendances) { FactoryBot.create_list(:attendance, 5, event: event, status: :cancelled) }
        it 'assign the instances variables and renders the template' do
          user.organized_events << event
          user.save

          get :attendance_organization_size, params: { event_id: event }
          expect(response).to render_template :attendance_organization_size
          expect(assigns(:attendance_organization_size_data)).to eq(event.attendances.active.group(:organization_size).count.to_a.map { |x| x.map { |x_part| x_part || I18n.t('report.common.unknown') } })
        end
      end

      describe 'GET #attendance_years_of_experience' do
        let(:event) { FactoryBot.create :event }
        let!(:attendances) { FactoryBot.create_list(:attendance, 10, event: event) }
        let!(:no_company_attendances) { FactoryBot.create_list(:attendance, 2, event: event, organization_size: nil) }
        let!(:cancelled_attendances) { FactoryBot.create_list(:attendance, 5, event: event, status: :cancelled) }
        it 'assign the instances variables and renders the template' do
          user.organized_events << event
          user.save

          get :attendance_years_of_experience, params: { event_id: event }
          expect(response).to render_template :attendance_years_of_experience
          expect(assigns(:attendance_years_of_experience_data)).to eq(event.attendances.active.group(:years_of_experience).count.to_a.map { |x| x.map { |x_part| x_part || I18n.t('report.common.unknown') } })
        end
      end

      describe 'GET #attendance_job_role' do
        let(:event) { FactoryBot.create :event }
        let!(:attendances) { FactoryBot.create_list(:attendance, 10, event: event) }
        let!(:no_company_attendances) { FactoryBot.create_list(:attendance, 2, event: event, organization_size: nil) }
        let!(:cancelled_attendances) { FactoryBot.create_list(:attendance, 5, event: event, status: :cancelled) }
        it 'assign the instances variables and renders the template' do
          user.organized_events << event
          user.save

          get :attendance_job_role, params: { event_id: event }
          expect(response).to render_template :attendance_job_role
          expect(assigns(:attendance_job_role_data)).to eq(event.attendances.active.group(:job_role).count.to_a.map { |x| x.map { |x_part| x_part || I18n.t('report.common.unknown') } })
        end
      end

      describe 'GET #burnup_registrations' do
        context 'with a valid event' do
          let!(:event) { FactoryBot.create :event, organizers: [user] }
          it 'calls the service and renders the template' do
            ReportService.instance.expects(:create_burnup_structure).with(event).once.returns(BurnupPresenter.new([], []))
            get :burnup_registrations, params: { event_id: event }
            expect(response).to render_template :burnup_registrations
          end
        end
        context 'with an invalid event' do
          it 'calls the service and renders the template' do
            get :burnup_registrations, params: { event_id: 'foo' }
            expect(response).to be_not_found
          end
        end
      end

      describe '#by_state' do
        let(:event) { FactoryBot.create(:event, organizers: [user]) }

        context 'with no attendances' do
          before { get :by_state, params: { event_id: event } }
          it { expect(assigns(:attendances_state_grouped)).to eq({}) }
        end

        context 'with attendances' do
          let!(:carioca_attendance) { FactoryBot.create(:attendance, event: event, state: 'RJ') }
          context 'with one attendance' do
            before { get :by_state, params: { event_id: event } }
            it { expect(assigns(:attendances_state_grouped)).to eq('RJ' => 1) }
          end

          context 'with two attendances on same state' do
            let!(:other_carioca) { FactoryBot.create(:attendance, event: event, state: 'RJ') }
            before { get :by_state, params: { event_id: event } }
            it { expect(assigns(:attendances_state_grouped)).to eq('RJ' => 2) }
          end

          context 'with two attendances in different states' do
            let!(:paulista_attendance) { FactoryBot.create(:attendance, event: event, state: 'SP') }
            before { get :by_state, params: { event_id: event } }
            it { expect(assigns(:attendances_state_grouped)).to eq('RJ' => 1, 'SP' => 1) }
          end

          context 'with two attendances one active and other not' do
            let!(:paulista_attendance) { FactoryBot.create(:attendance, event: event, state: 'SP', status: 'cancelled') }
            before { get :by_state, params: { event_id: event } }
            it { expect(assigns(:attendances_state_grouped)).to eq('RJ' => 1) }
          end
        end
      end

      describe '#by_city' do
        let(:event) { FactoryBot.create(:event, organizers: [user]) }

        context 'with no attendances' do
          before { get :by_city, params: { event_id: event } }
          it { expect(assigns(:attendances_city_grouped)).to eq({}) }
        end

        context 'with attendances' do
          let!(:carioca_attendance) { FactoryBot.create(:attendance, event: event, state: 'RJ', city: 'Rio de Janeiro') }
          context 'with one attendance' do
            before { get :by_city, params: { event_id: event } }
            it { expect(assigns(:attendances_city_grouped)).to eq(['Rio de Janeiro', 'RJ'] => 1) }
          end

          context 'with two attendances on same state' do
            let!(:other_carioca) { FactoryBot.create(:attendance, event: event, state: 'RJ', city: 'Rio de Janeiro') }
            before { get :by_city, params: { event_id: event } }
            it { expect(assigns(:attendances_city_grouped)).to eq(['Rio de Janeiro', 'RJ'] => 2) }
          end

          context 'with two attendances in different states' do
            let!(:paulista_attendance) { FactoryBot.create(:attendance, event: event, state: 'SP', city: 'Sao Paulo') }
            before { get :by_city, params: { event_id: event } }
            it { expect(assigns(:attendances_city_grouped)).to eq(['Rio de Janeiro', 'RJ'] => 1, ['Sao Paulo', 'SP'] => 1) }
          end

          context 'with two attendances one active and other not' do
            let!(:paulista_attendance) { FactoryBot.create(:attendance, event: event, state: 'SP', city: 'Sao Paulo', status: 'cancelled') }
            before { get :by_city, params: { event_id: event } }
            it { expect(assigns(:attendances_city_grouped)).to eq(['Rio de Janeiro', 'RJ'] => 1) }
          end
        end
      end

      describe '#last_biweekly_active' do
        let(:event) { FactoryBot.create(:event, organizers: [user]) }

        context 'with no attendances' do
          before { get :last_biweekly_active, params: { event_id: event } }
          it { expect(assigns(:attendances_biweekly_grouped)).to eq({}) }
        end

        context 'with attendances' do
          it 'returns just the attendances within two weeks ago' do
            now = Time.zone.local(2015, 4, 30, 0, 0, 0)
            travel_to(now)
            last_week = FactoryBot.create(:attendance, event: event, created_at: 7.days.ago)
            FactoryBot.create(:attendance, event: event, created_at: 7.days.ago)
            today = FactoryBot.create(:attendance, event: event)
            FactoryBot.create(:attendance, event: event, created_at: 21.days.ago)
            FactoryBot.create(:attendance)
            get :last_biweekly_active, params: { event_id: event }
            expect(assigns(:attendances_biweekly_grouped)).to eq(last_week.created_at.to_date => 2, today.created_at.to_date => 1)
            travel_back
          end
        end
      end

      describe '#payment_type_report' do
        let(:event) { FactoryBot.create(:event, organizers: [user]) }

        context 'with no attendances' do
          before { get :payment_type_report, params: { event_id: event } }
          it { expect(assigns(:payment_type_report)).to eq({}) }
        end

        context 'with attendances' do
          let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending, payment_type: 'gateway') }
          let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid, payment_type: 'gateway') }
          let!(:valued) { FactoryBot.create(:attendance, event: event, status: :paid, payment_type: 'gateway', registration_value: 123) }
          let!(:grouped) { FactoryBot.create(:attendance, event: event, status: :paid, payment_type: 'gateway') }
          let!(:confirmed) { FactoryBot.create(:attendance, event: event, status: :confirmed, payment_type: 'bank_deposit') }
          let!(:other_confirmed) { FactoryBot.create(:attendance, event: event, status: :confirmed, payment_type: 'statement_agreement') }
          let!(:free) { FactoryBot.create(:attendance, event: event, status: :confirmed, payment_type: 'statement_agreement', registration_value: 0) }

          let!(:cancelled) { FactoryBot.create(:attendance, event: event, status: :cancelled, payment_type: 'gateway') }
          let!(:out_of_event) { FactoryBot.create(:attendance, status: :paid, payment_type: 'gateway') }

          it 'returns the attendances with non free registration value grouped by payment type' do
            get :payment_type_report, params: { event_id: event }
            expect(assigns(:payment_type_report)).to eq(['bank_deposit', 400] => 1, ['gateway', 400] => 2, ['statement_agreement', 400] => 1, ['gateway', 123] => 1)
          end
        end
      end
    end

    context 'and is not organizing the event' do
      describe 'GET #attendance_organization_size' do
        let(:event) { FactoryBot.create :event }
        before { get :attendance_organization_size, params: { event_id: event } }
        it { expect(response).to be_not_found }
      end

      describe 'GET #attendance_years_of_experience' do
        let(:event) { FactoryBot.create :event }
        before { get :attendance_years_of_experience, params: { event_id: event } }
        it { expect(response).to be_not_found }
      end

      describe 'GET #attendance_job_role' do
        let(:event) { FactoryBot.create :event }
        before { get :attendance_job_role, params: { event_id: event } }
        it { expect(response).to be_not_found }
      end

      describe 'GET #burnup_registrations' do
        before { get :burnup_registrations, params: { event_id: 'foo' } }
        it { expect(response).to be_not_found }
      end
    end
  end
end
