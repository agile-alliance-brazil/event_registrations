# frozen_string_literal: true

RSpec.describe ApplicationController, type: :controller do
  describe '#switch_locale' do
    controller do
      def index
        head :ok, params: { content_type: 'text/html' }
      end
    end

    context 'with no request parameter' do
      it 'uses the en locale' do
        routes.draw { get 'index' => 'anonymous#index' }

        get :index
        expect(I18n.locale).to eq I18n.default_locale
      end
    end

    context 'with pt as browser language' do
      it 'uses the pt locale' do
        routes.draw { get 'index' => 'anonymous#index' }

        request.headers['HTTP_ACCEPT_LANGUAGE'] = 'en-US,en;q=0.9,pt-BR;q=0.8,pt;q=0.7'
        get :index
        expect(I18n.locale).to eq :pt
      end
    end

    context 'without pt as browser language' do
      it 'uses the en locale' do
        routes.draw { get 'index' => 'anonymous#index' }

        request.headers['HTTP_ACCEPT_LANGUAGE'] = 'en-US,en;q=0.9'
        get :index
        expect(I18n.locale).to eq :en
      end
    end
  end
end
