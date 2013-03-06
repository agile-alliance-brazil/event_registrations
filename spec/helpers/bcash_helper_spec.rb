# encoding: UTF-8
require 'spec_helper'

describe BcashHelper do
  describe "add_config_vars" do
    it "should add return url and notification url" do
      params = {}
      helper.add_bcash_config_vars(params, 'return_url', 'notify_url')

      params[:url_retorno].should == 'return_url'
      params[:url_aviso].should == 'notify_url'
    end
  end
end