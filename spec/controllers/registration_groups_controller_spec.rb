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
  end

  describe '#destroy' do
    context 'valid data' do
      let!(:group) { FactoryGirl.create :registration_group }
      before { delete :destroy, event_id: group.event.id, id: group.id }
      it { expect(RegistrationGroup.count).to be 0 }
      it { expect(response).to redirect_to event_registration_groups_path(group.event) }
      it { expect(flash[:notice]).to eq I18n.t('registration_group.destroy.success') }
    end
  end
end
