# frozen_string_literal: true

RSpec.describe EventsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #index' do
      context 'without events at the right period' do
        before { get :index }

        it { expect(assigns(:events)).to eq [] }
      end

      context 'with events' do
        let!(:event) { Fabricate(:event, name: 'Foo', start_date: Time.zone.today - 1, end_date: 1.month.from_now) }

        context 'and one event at the right period' do
          before { get :index }

          it { expect(assigns(:events)).to match_array [event] }
        end

        context 'and two at the right period' do
          let!(:other_event) { Fabricate(:event, start_date: Time.zone.today - 1, end_date: 2.months.from_now) }

          before { get :index }

          it { expect(assigns(:events)).to match_array [event, other_event] }
        end

        context 'and one at the right period and other not' do
          let!(:out) { Fabricate(:event, start_date: 2.years.ago, end_date: 1.year.ago) }

          before { get :index }

          it { expect(assigns(:events)).to match_array [event] }
        end

        context 'and two at the right period and other not' do
          let!(:other_event) { Fabricate(:event, start_date: Time.zone.today - 1, end_date: 2.months.from_now) }
          let!(:out) { Fabricate(:event, start_date: 2.years.ago, end_date: 1.year.ago) }

          before { get :index }

          it { expect(assigns(:events)).to match_array [event, other_event] }
        end
      end
    end

    describe 'GET #list_archived' do
      before { get :list_archived }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #new' do
      before { get :new }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE destroy' do
      before { delete :destroy, params: { id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #add_organizer' do
      before { patch :add_organizer, params: { id: 'foo' }, xhr: true }

      it { expect(response).to have_http_status :unauthorized }
    end

    describe 'GET #edit' do
      before { get :edit, params: { id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'logged as normal user' do
    let(:user) { Fabricate(:user) }

    before { sign_in user }

    describe 'GET #list_archived' do
      before { get :list_archived }

      it { expect(response).to have_http_status :not_found }
    end

    describe 'GET #new' do
      before { get :new }

      it { expect(response).to have_http_status :not_found }
    end

    describe 'POST #create' do
      before { post :create }

      it { expect(response).to have_http_status :not_found }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { id: 'foo' } }

      it { expect(response).to have_http_status :not_found }
    end

    describe 'PATCH #add_organizer' do
      before { patch :add_organizer, params: { id: 'foo' }, xhr: true }

      it { expect(response).to have_http_status :not_found }
    end

    describe 'GET #edit' do
      before { get :edit, params: { id: 'foo' } }

      it { expect(response).to have_http_status :not_found }
    end

    describe 'PUT #update' do
      before { put :update, params: { id: 'foo' } }

      it { expect(response).to have_http_status :not_found }
    end
  end

  context 'logged as organizer' do
    let(:organizer) { Fabricate(:user, role: :organizer) }
    let(:event) { Fabricate :event, organizers: [organizer] }

    before { sign_in organizer }

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { id: 'foo' } }

      it { expect(response).to have_http_status :not_found }
    end

    describe 'GET #edit' do
      context 'and valid event ID' do
        it 'assigns the instance variable and renders the template' do
          get :edit, params: { id: event }
          expect(response).to have_http_status :ok
          expect(response).to render_template :edit
          expect(assigns(:event)).to eq event
        end
      end

      context 'and invalid event ID' do
        it 'responds 404' do
          get :edit, params: { id: 'foo' }
          expect(response).to have_http_status :not_found
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid parameters' do
        it 'updates the event' do
          start_date = Time.zone.now
          end_date = 1.week.from_now
          put :update, params: { id: event, event: { event_image: 'bla', name: 'name', attendance_limit: 65, days_to_charge: 5, start_date: start_date, end_date: end_date, main_email_contact: 'contact@foo.com.br', full_price: 278, privacy_policy: 'http://foo.com' } }
          event_updated = event.reload
          expect(response).to redirect_to event_path(event_updated)
          expect(event_updated.event_image).not_to be_nil
          expect(event_updated.name).to eq 'name'
          expect(event_updated.attendance_limit).to eq 65
          expect(event_updated.days_to_charge).to eq 5
          expect(event_updated.start_date.utc.to_i).to eq start_date.to_i
          expect(event_updated.end_date.utc.to_i).to eq end_date.to_i
          expect(event_updated.full_price).to eq 278
          expect(event_updated.privacy_policy).to eq 'http://foo.com'
        end
      end

      context 'with invalid parameters' do
        before { put :update, params: { id: event, event: { name: '', attendance_limit: nil, days_to_charge: nil, start_date: '', end_date: '', full_price: '' } } }

        it 'renderes the form with the errors' do
          expect(response).to render_template :edit
          expect(assigns(:event).errors.full_messages).to eq ['Inicia em: não pode ficar em branco', 'Termina em: não pode ficar em branco', 'Preço cheio: não pode ficar em branco', 'Nome: não pode ficar em branco', 'Capacidade: não pode ficar em branco']
        end
      end

      context 'with invalid event ID' do
        it 'responds 404' do
          put :update, params: { id: 'foo' }
          expect(response).to have_http_status :not_found
        end
      end
    end
  end

  context 'logged as admin' do
    let(:admin) { Fabricate(:user, role: :admin) }

    before { sign_in admin }

    describe 'GET #list_archived' do
      context 'without events' do
        before { get :list_archived }

        it { expect(assigns(:events)).to match_array [] }
        it { expect(response).not_to render_template :index }
      end

      context 'having events' do
        let!(:event) { Fabricate(:event, name: 'Foo', start_date: 3.months.ago, end_date: 2.months.ago) }
        let!(:other_event) { Fabricate(:event, start_date: 2.months.ago, end_date: 1.month.ago) }

        before { get :list_archived }

        it { expect(assigns(:events)).to eq [other_event, event] }
      end
    end

    describe 'GET #new' do
      it 'assigns the event and render the new template' do
        get :new
        expect(assigns(:event)).to be_a_new Event
        expect(response).to render_template :new
      end
    end

    describe 'POST #create' do
      context 'with valid parameters' do
        it 'creates the event and redirects to index of events' do
          start_date = Time.zone.now
          end_date = 1.week.from_now
          post :create, params: { event: { event_image: 'bla', name: 'foo', attendance_limit: 10, days_to_charge: 3, start_date: start_date, end_date: end_date, main_email_contact: 'contact@foo.com.br', full_price: 100, city: 'foo', state: 'bar', country: 'BR', event_nickname: 'xpto', event_remote: true, event_remote_platform_mail: 'foo@bar.com', event_remote_platform_name: 'barfoo', event_schedule_link: 'bar.com', event_remote_manual_link: 'xpto.com', privacy_policy: 'http://foo.com' } }
          expect(Event.count).to eq 1
          event_persisted = Event.last
          expect(event_persisted.event_image).not_to be_nil
          expect(event_persisted.name).to eq 'foo'
          expect(event_persisted.attendance_limit).to eq 10
          expect(event_persisted.days_to_charge).to eq 3
          expect(event_persisted.start_date.utc.to_i).to eq start_date.to_i
          expect(event_persisted.end_date.utc.to_i).to eq end_date.to_i
          expect(event_persisted.full_price).to eq 100
          expect(event_persisted.event_nickname).to eq 'xpto'
          expect(event_persisted.event_remote).to be true
          expect(event_persisted.event_remote_platform_mail).to eq 'foo@bar.com'
          expect(event_persisted.event_remote_platform_name).to eq 'barfoo'
          expect(event_persisted.event_schedule_link).to eq 'bar.com'
          expect(event_persisted.event_remote_manual_link).to eq 'xpto.com'
          expect(event_persisted.privacy_policy).to eq 'http://foo.com'

          expect(response).to redirect_to event_path(event_persisted)
        end
      end

      context 'with invalid parameters' do
        subject(:event) { assigns(:event) }

        before { post :create, params: { event: { name: '' } } }

        it 'renders form with the errors' do
          expect(event).to be_a Event
          expect(event.errors.full_messages).to eq ['Inicia em: não pode ficar em branco', 'Termina em: não pode ficar em branco', 'Preço cheio: não pode ficar em branco', 'Nome: não pode ficar em branco', 'E-mail de Contato: não pode ficar em branco', 'Capacidade: não pode ficar em branco', 'País: não pode ficar em branco', 'Estado: não pode ficar em branco', 'Cidade: não pode ficar em branco']
          expect(response).to render_template :new
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'with valid parameters' do
        context 'and responding to HTML' do
          let!(:event) { Fabricate :event }

          it 'deletes the event and redirects to events index' do
            delete :destroy, params: { id: event.id }
            expect(response).to redirect_to events_path
            expect(Event.count).to eq 0
          end
        end
      end

      context 'with invalid parameters' do
        it 'responds 404' do
          delete :destroy, params: { id: 'foo' }
          expect(response.status).to eq 404
        end
      end
    end

    describe 'PATCH #add_organizer' do
      let(:event) { Fabricate :event }

      context 'with invalid parameters' do
        context 'and invalid event' do
          it 'responds 404' do
            patch :add_organizer, params: { id: 'foo' }, xhr: true
            expect(response.status).to eq 404
          end
        end

        context 'and invalid organizer email' do
          context 'passing an invalid organizer' do
            it 'responds 404' do
              patch :add_organizer, params: { id: event, organizer: 'foo' }, xhr: true
              expect(response.status).to eq 404
            end
          end

          context 'passing a valid email and the user is not organizer' do
            let(:not_organizer) { Fabricate :user }

            it 'responds 404' do
              patch :add_organizer, params: { id: event, organizer: not_organizer }, xhr: true
              expect(response.status).to eq 404
            end
          end
        end
      end

      context 'with valid parameters' do
        context 'and the user has the organizer role' do
          let(:organizer) { Fabricate(:user, role: :organizer) }

          it 'adds the user as organizer' do
            patch :add_organizer, params: { id: event, organizer: organizer }, xhr: true
            expect(response.status).to eq 200
            expect(event.reload.organizers).to include organizer
          end
        end

        context 'and the user is already an organizer' do
          let(:organizer) { Fabricate(:user, role: :organizer) }

          before do
            event.organizers << organizer
            event.save!
          end

          it 'adds the user as organizer' do
            patch :add_organizer, params: { id: event, organizer: organizer }, xhr: true
            expect(response.status).to eq 200
            expect(event.reload.organizers.count).to eq 1
          end
        end

        context 'and the user has the admin role' do
          let(:admin) { Fabricate :user, role: :admin }

          it 'adds the user as organizer' do
            patch :add_organizer, params: { id: event, organizer: admin }, xhr: true
            expect(response.status).to eq 200
            expect(event.reload.organizers).to include admin
          end
        end
      end
    end

    describe 'DELETE #remove_organizer' do
      let(:event) { Fabricate :event }

      context 'with invalid parameters' do
        context 'and invalid event' do
          it 'responds 404' do
            delete :remove_organizer, params: { id: 'foo' }, xhr: true
            expect(response.status).to eq 404
          end
        end

        context 'and invalid organizer email' do
          context 'passing an invalid email' do
            it 'responds 404' do
              delete :remove_organizer, params: { id: event, organizer: 'bla' }, xhr: true
              expect(response.status).to eq 404
            end
          end
        end
      end

      context 'with valid parameters' do
        context 'and the user is already an organizer' do
          let!(:organizer) { Fabricate :user, role: :organizer }

          it 'removes the organizer' do
            delete :remove_organizer, params: { id: event, organizer: organizer }, xhr: true
            expect(event.reload.organizers).not_to include organizer
            expect(response).to render_template 'events/add_organizer'
          end
        end

        context 'and the user is not an organizer of the event' do
          let(:organizer) { Fabricate(:user, role: :organizer) }
          let(:other_organizer) { Fabricate :user, role: :organizer }

          it 'adds the user as organizer' do
            event.add_organizer(other_organizer)
            delete :remove_organizer, params: { id: event, organizer: organizer }, xhr: true
            expect(event.reload.organizers.count).to eq 1
          end
        end
      end
    end
  end

  describe 'GET #show' do
    let!(:event) { Fabricate :event }

    context 'with an existent user' do
      before { get :show, params: { id: event.id } }

      it 'assigns the instance variable and renders the template' do
        expect(assigns(:event)).to eq event
        expect(assigns(:last_attendance_for_user)).to be_nil
        expect(response).to render_template :show
      end
    end

    context 'with invalid parameters' do
      it 'responds 404' do
        get :show, params: { id: 'foo' }
        expect(response.status).to eq 404
      end
    end

    context 'signed in' do
      let(:user) { Fabricate(:user) }

      before { sign_in user }

      context 'with two valid attendances, the first cancelled and second pending' do
        it 'assigns the instance variable with the last attendance and renders the template' do
          Fabricate(:attendance, event: event, user: user, status: :cancelled, created_at: 1.day.ago)
          other_attendance = Fabricate(:attendance, event: event, user: user, status: :pending, created_at: Time.zone.now)
          get :show, params: { id: event.id }
          expect(assigns[:last_attendance_for_user]).to eq other_attendance
        end
      end

      context 'with two valid attendances, one in an event and the second in other event' do
        let(:other_event) { Fabricate(:event) }
        let!(:attendance) { Fabricate(:attendance, event: event, user: user) }
        let!(:other_attendance) { Fabricate(:attendance, event: other_event, user: user) }

        before { get :show, params: { id: event.id } }

        it { expect(assigns[:last_attendance_for_user]).to eq attendance }
      end
    end
  end
end
