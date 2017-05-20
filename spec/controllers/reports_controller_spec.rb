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
  end

  context 'authenticated as organizer' do
    let(:user) { FactoryGirl.create :user, roles: [:organizer] }
    before { sign_in user }

    context 'and is organizing the event' do
      describe 'GET #attendance_organization_size' do
        let(:event) { FactoryGirl.create :event }
        let!(:attendances) { FactoryGirl.create_list(:attendance, 10, event: event) }
        let!(:no_company_attendances) { FactoryGirl.create_list(:attendance, 2, event: event, organization_size: nil) }
        let!(:cancelled_attendances) { FactoryGirl.create_list(:attendance, 5, event: event, status: :cancelled) }
        it 'assign the instances variables and renders the template' do
          user.organized_events << event
          user.save

          get :attendance_organization_size, params: { event_id: event }
          expect(response).to render_template :attendance_organization_size
          expect(assigns(:attendance_organization_size_data)).to eq(event.attendances.active.group(:organization_size).count.to_a.map { |x| x.map { |x_part| x_part || I18n.t('report.common.unknown') } })
        end
      end

      describe 'GET #attendance_years_of_experience' do
        let(:event) { FactoryGirl.create :event }
        let!(:attendances) { FactoryGirl.create_list(:attendance, 10, event: event) }
        let!(:no_company_attendances) { FactoryGirl.create_list(:attendance, 2, event: event, organization_size: nil) }
        let!(:cancelled_attendances) { FactoryGirl.create_list(:attendance, 5, event: event, status: :cancelled) }
        it 'assign the instances variables and renders the template' do
          user.organized_events << event
          user.save

          get :attendance_years_of_experience, params: { event_id: event }
          expect(response).to render_template :attendance_years_of_experience
          expect(assigns(:attendance_years_of_experience_data)).to eq(event.attendances.active.group(:years_of_experience).count.to_a.map { |x| x.map { |x_part| x_part || I18n.t('report.common.unknown') } })
        end
      end

      describe 'GET #attendance_job_role' do
        let(:event) { FactoryGirl.create :event }
        let!(:attendances) { FactoryGirl.create_list(:attendance, 10, event: event) }
        let!(:no_company_attendances) { FactoryGirl.create_list(:attendance, 2, event: event, organization_size: nil) }
        let!(:cancelled_attendances) { FactoryGirl.create_list(:attendance, 5, event: event, status: :cancelled) }
        it 'assign the instances variables and renders the template' do
          user.organized_events << event
          user.save

          get :attendance_job_role, params: { event_id: event }
          expect(response).to render_template :attendance_job_role
          expect(assigns(:attendance_job_role_data)).to eq(event.attendances.active.group(:job_role).count.to_a.map { |x| x.map { |x_part| x_part || I18n.t('report.common.unknown') } })
        end
      end
    end

    context 'and is not organizing the event' do
      describe 'GET #attendance_organization_size' do
        let(:event) { FactoryGirl.create :event }
        before { get :attendance_organization_size, params: { event_id: event } }
        it { expect(response).to have_http_status :not_found }
      end

      describe 'GET #attendance_years_of_experience' do
        let(:event) { FactoryGirl.create :event }
        before { get :attendance_years_of_experience, params: { event_id: event } }
        it { expect(response).to have_http_status :not_found }
      end

      describe 'GET #attendance_job_role' do
        let(:event) { FactoryGirl.create :event }
        before { get :attendance_job_role, params: { event_id: event } }
        it { expect(response).to have_http_status :not_found }
      end
    end
  end
end