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

      context 'instance variables' do
        before { get :index, event_id: event }
        it { expect(assigns(:new_group)).not_to be_nil }
      end

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

  describe '#show' do
    let(:event) { FactoryGirl.create :event }
    let!(:group) { FactoryGirl.create :registration_group, event: event }
    let!(:invoice) { FactoryGirl.create :invoice, registration_group: group, status: Invoice::PAID }
    before { get :show, event_id: event.id, id: group.id }
    it { expect(assigns(:group)).to eq group }
    it { expect(assigns(:invoice)).to eq invoice }
    it { expect(response).to render_template :show }

    pending 'renew invoice when is not paid or sent.'
    pending 'check if is possible to renew or cancel a paid or sent invoice.'
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

  describe '#create' do
    let(:event) { FactoryGirl.create :event }
    let(:valid_params) { { name: 'new_group', discount: 5, minimum_size: 10 } }
    before { post :create, event_id: event, registration_group: valid_params }
    subject(:new_group) { RegistrationGroup.last }
    it { expect(new_group.event).to eq event }
    it { expect(new_group.name).to eq 'new_group' }
    it { expect(new_group.discount).to eq 5 }
    it { expect(new_group.minimum_size).to eq 10 }
    it { expect(new_group.token).not_to be_blank }
  end
end
