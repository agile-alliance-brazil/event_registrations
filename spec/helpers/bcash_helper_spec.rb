# encoding: UTF-8
require 'spec_helper'

describe BcashHelper, type: :helper do
  describe 'add_config_vars' do
    it 'should add return url and notification url' do
      params = {}
      helper.add_bcash_config_vars(params, 'return_url', 'notify_url')

      expect(params[:url_retorno]).to eq('return_url')
      expect(params[:url_aviso]).to eq('notify_url')
    end
  end
end