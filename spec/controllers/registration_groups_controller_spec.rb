# frozen_string_literal: true

RSpec.describe RegistrationGroupsController, type: :controller do
  let(:admin) { Fabricate :user, role: :admin }
  let(:event) { Fabricate :event }

  before { sign_in admin }

  describe 'GET #new' do
    context 'with valid data' do
      let!(:group) { Fabricate :registration_group, event: event }
      let!(:other_group) { Fabricate :registration_group, event: event }
      let!(:other_event_group) { Fabricate :registration_group }

      it 'assign the instance variables and renders the template' do
        get :new, params: { event_id: event }
        expect(assigns(:group)).to be_a_new RegistrationGroup
        expect(response).to render_template :new
      end
    end

    context 'with invalid event' do
      before { get :new, params: { event_id: 'foo' } }

      it { expect(response).to have_http_status :not_found }
    end
  end

  describe 'GET #show' do
    let(:group) { Fabricate :registration_group, event: event }

    context 'without attendances' do
      before { get :show, params: { event_id: event.id, id: group.id } }

      it { expect(assigns(:group)).to eq group }
      it { expect(response).to render_template :show }
    end

    context 'with attendances' do
      let!(:first_attendance) { Fabricate(:attendance, registration_group: group, created_at: 2.days.ago) }
      let!(:second_attendance) { Fabricate(:attendance, registration_group: group, created_at: 3.days.ago) }
      let!(:third_attendance) { Fabricate(:attendance, registration_group: group, created_at: 5.days.ago) }

      it 'assigns the group and the attendance list and renders the template' do
        get :show, params: { event_id: event.id, id: group.id }

        attendance_list = Attendance.all.order(created_at: :desc)
        expect(assigns(:attendance_list)).to eq attendance_list
        expect(assigns(:attendance_list_csv)).to eq AttendanceExportService.to_csv(attendance_list)
        expect(response).to render_template 'registration_groups/show'
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:group) { Fabricate :registration_group, event: event }

    context 'with valid data' do
      context 'having attendances as dependencies' do
        let!(:attendance) { Fabricate(:attendance, event: event, registration_group: group) }

        it 'does not destroy the group and redirects with an error message' do
          expect(RegistrationGroup.count).to eq 1
          expect(Attendance.count).to eq 1

          delete :destroy, params: { event_id: event, id: group }
          expect(RegistrationGroup.count).to eq 1
          expect(Attendance.count).to eq 1
          expect(response).to redirect_to event_registration_groups_path(event)
          expect(flash[:error]).to eq 'Não é possível excluir o registro pois existem inscritos dependentes'
        end
      end
    end

    context 'with invalid' do
      context 'event' do
        before { delete :destroy, params: { event_id: 'foo', id: group } }

        it { expect(response).to have_http_status :not_found }
      end

      context 'registration group' do
        before { delete :destroy, params: { event_id: event, id: 'foo' } }

        it { expect(response).to have_http_status :not_found }
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      subject(:new_group) { RegistrationGroup.last }

      let(:valid_params) { { name: 'new_group', discount: 5, minimum_size: 10, amount: 137, capacity: 100, paid_in_advance: true } }

      before { post :create, params: { event_id: event, registration_group: valid_params } }

      it 'creates the group and redirects' do
        expect(new_group.event).to eq event
        expect(new_group.name).to eq 'new_group'
        expect(new_group.discount).to eq 5
        expect(new_group.minimum_size).to eq 10
        expect(new_group.amount).to eq 137
        expect(new_group).to be_paid_in_advance
        expect(new_group.capacity).to eq 100
        expect(new_group.token).not_to be_blank

        expect(response).to redirect_to event_path(event)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { name: '', discount: nil, minimum_size: nil, amount: nil } }

      before { post :create, params: { event_id: event, registration_group: invalid_params } }

      it 'does not create the group and re-render the form with the errors' do
        expect(RegistrationGroup.last).to be_nil
        expect(assigns(:group).errors.full_messages).to eq ['Nome: não pode ficar em branco', 'Desconto (%): Ou o desconto ou o valor das inscrições no grupo deve estar preenchido.', 'Valor das inscrições no grupo: Ou o desconto ou o valor das inscrições no grupo deve estar preenchido.']
      end
    end
  end

  describe 'GET #edit' do
    let(:group) { Fabricate :registration_group, event: event }

    context 'with valid IDs' do
      it 'assigns the instance variable and renders the template' do
        get :edit, params: { event_id: event, id: group }
        expect(assigns(:group)).to eq group
        expect(response).to render_template :edit
      end
    end

    context 'with invalid IDs' do
      context 'and no valid event and group' do
        it 'does not assign the instance variable responds 404' do
          get :edit, params: { event_id: 'foo', id: 'bar' }
          expect(assigns(:group)).to be_nil
          expect(response.status).to eq 404
        end
      end

      context 'and an invalid event' do
        it 'responds 404' do
          get :edit, params: { event_id: 'foo', id: group }
          expect(response.status).to eq 404
        end
      end

      context 'and a group for other event' do
        let(:other_event) { Fabricate :event }
        let(:group) { Fabricate :registration_group, event: other_event }

        it 'does not assign the instance variable responds 404' do
          get :edit, params: { event_id: event, id: group }
          expect(assigns(:group)).to be_nil
          expect(response.status).to eq 404
        end
      end
    end
  end

  describe 'PUT #update' do
    let(:group) { Fabricate :registration_group, event: event }
    let(:start_date) { Time.zone.now }
    let(:end_date) { 1.week.from_now }
    let(:valid_parameters) { { name: 'updated_group', discount: 5, minimum_size: 10, amount: 137 } }

    context 'with valid parameters' do
      it 'updates and redirects to event show' do
        put :update, params: { event_id: event, id: group, registration_group: valid_parameters }
        updated_group = RegistrationGroup.last
        expect(updated_group.name).to eq 'updated_group'
        expect(updated_group.discount).to eq 5
        expect(updated_group.minimum_size).to eq 10
        expect(updated_group.amount).to eq 137
        expect(updated_group.token).not_to be_blank
        expect(response).to redirect_to event
      end
    end

    context 'with invalid parameters' do
      let(:invalid_parameters) { { name: '', discount: nil, minimum_size: nil, amount: nil } }

      context 'and valid event and group, but invalid update parameters' do
        it 'does not update and render form with errors' do
          put :update, params: { event_id: event, id: group, registration_group: invalid_parameters }
          updated_group = assigns(:group)
          expect(updated_group.errors.full_messages).to eq ['Nome: não pode ficar em branco', 'Desconto (%): Ou o desconto ou o valor das inscrições no grupo deve estar preenchido.', 'Valor das inscrições no grupo: Ou o desconto ou o valor das inscrições no grupo deve estar preenchido.']
          expect(response).to render_template :edit
        end
      end

      context 'with invalid IDs' do
        context 'and no valid event and group' do
          it 'does not assign the instance variable responds 404' do
            put :update, params: { event_id: 'bar', id: 'foo', registration_group: valid_parameters }
            expect(assigns(:registration_group)).to be_nil
            expect(response.status).to eq 404
          end
        end

        context 'and an invalid event' do
          it 'responds 404' do
            put :update, params: { event_id: 'bar', id: group, registration_group: valid_parameters }
            expect(response.status).to eq 404
          end
        end

        context 'and a group for other event' do
          let(:other_event) { Fabricate :event }
          let(:group) { Fabricate :registration_group, event: other_event }

          it 'does not assign the instance variable responds 404' do
            put :update, params: { event_id: event, id: group, registration_group: valid_parameters }
            expect(assigns(:group)).to be_nil
            expect(response.status).to eq 404
          end
        end
      end
    end
  end
end
