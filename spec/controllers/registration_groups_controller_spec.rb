describe RegistrationGroupsController, type: :controller do
  let(:user) { FactoryGirl.create :user }
  before do
    user.add_role(:admin)
    user.save
    sign_in user
  end

  describe '#index' do

    context 'with valid data' do
      let(:event) { FactoryGirl.create :event }
      let!(:group) { FactoryGirl.create :registration_group, event: event }
      context 'and an existent group for event' do
        before { get :index, event_id: event }
        it { expect(assigns(:groups)).to match_array [group] }
        it { expect(response).to render_template :index }
      end

      context 'and two groups for event' do
        let!(:other_group) { FactoryGirl.create :registration_group, event: event }
        before { get :index, event_id: event }
        it { expect(assigns(:groups)).to match_array [group, other_group] }
        it { expect(response).to render_template :index }
      end

      context 'and two groups one for event and other not' do
        let!(:other_group) { FactoryGirl.create :registration_group, event: event }
        let!(:out) { FactoryGirl.create :registration_group }
        before { get :index, event_id: event }
        it { expect(assigns(:groups)).to match_array [group, other_group] }
        it { expect(response).to render_template :index }
      end
    end

    context 'with invalid data' do
      context 'and an existent group for event' do
        before { get :index, event_id: 'foo' }
        it { expect(assigns(:groups)).to be_nil }
        it { expect(response).to redirect_to events_path }
        it { expect(flash[:alert]).to eq I18n.t('event.not_found') }
      end
    end
  end
end
