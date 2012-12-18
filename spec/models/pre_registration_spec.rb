# encoding: UTF-8
require 'spec_helper'

describe PreRegistration do
  context "association" do
    it { should belong_to :event }
  end
  
  context "named scopes" do
    xit {should have_scope(:registered, :with => 'testing@GMAIL.com').where("UPPER(email) = UPPER('testing@GMAIL.com')") }
    
    it "should ignore case" do
      p = PreRegistration.new(:email => 'TESTING@gmail.com')
      p.save
      
      PreRegistration.registered('testing@GMAIL.com').first.should == p
      
      p.destroy
    end
  end
end
