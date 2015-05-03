describe UsersController, type: :controller do
  context 'authorized' do
    let!(:user) { FactoryGirl.create :user }
    before { sign_in user }

    describe '#show' do
      context 'with an existent user' do
        context 'with only one event available for date' do
          let!(:event) { FactoryGirl.create :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
          before { get :show, id: user.id }
          it { expect(assigns(:user)).to eq user }
          it { expect(assigns(:events_for_today)).to match_array [event] }
          it { expect(response).to render_template :show }
        end

        context 'with one event available and other with null at end date' do
          let!(:event) { FactoryGirl.create :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
          let!(:other_event) { FactoryGirl.create :event, start_date: Time.zone.yesterday, end_date: nil }
          before { get :show, id: user.id }
          it { expect(assigns(:events_for_today)).to match_array [event] }
        end
      end

      context 'with an inexistent user' do
        before { get :show, id: 'foo' }
        it { expect(assigns(:user)).to be_nil }
        it { expect(response.status).to eq 302 }
        it { expect(flash[:error]).to eq I18n.t('flash.unauthorised') }
      end
    end

    describe '#edit' do
      context 'with an existent user' do
        before { get :edit, id: user.id }
        it { expect(assigns(:user)).to eq user }
        it { expect(response).to render_template :edit }
      end

      context 'with an inexistent user' do
        before { get :edit, id: 'foo' }
        it { expect(assigns(:user)).to be_nil }
        it { expect(response.status).to eq 302 }
        it { expect(flash[:error]).to eq I18n.t('flash.unauthorised') }
      end
    end

    describe '#update' do
      let(:valid_params) { { first_name: 'xpto', last_name: 'bla', email: 'xpto@bla.com', email_confirmation: 'xpto@bla.com'} }

      context 'with an existent user' do
        before { put :update, id: user.id, user: valid_params }
        it { expect(User.last.first_name).to eq 'xpto' }
        it { expect(User.last.last_name).to eq 'bla' }
        it { expect(User.last.email).to eq 'xpto@bla.com' }
      end

      context 'with an inexistent user' do
        before { put :update, id: 'foo', user: valid_params }
        it { expect(assigns(:user)).to be_nil }
        it { expect(response.status).to eq 302 }
        it { expect(flash[:error]).to eq I18n.t('flash.unauthorised') }

        it { expect(User.last.first_name).to eq user.first_name }
        it { expect(User.last.last_name).to eq user.last_name }
        it { expect(User.last.email).to eq user.email }
      end

      context 'with failed update attributes' do
        before { put :update, id: user.id, user: { first_name: '' } }
        it { expect(flash[:error]).to eq I18n.t('flash.user.edit') }
        it { expect(response).to render_template :edit }

        it { expect(User.last.first_name).to eq user.first_name }
        it { expect(User.last.last_name).to eq user.last_name }
        it { expect(User.last.email).to eq user.email }
      end
    end
  end
end
