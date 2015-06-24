# encoding: UTF-8
require 'spec_helper'

describe PaypalHelper, type: :helper do
  describe 'add_config_vars' do
    it 'should add return url and notification url' do
      params = {}
      helper.add_paypal_config_vars(params, 'return_url', 'notify_url')

      expect(params[:return]).to eq('return_url')
      expect(params[:cancel_return]).to eq('return_url')
      expect(params[:notify_url]).to eq('notify_url')
    end
  end
end
