# encoding: UTF-8
require 'spec_helper'
require File.join(Rails.root, '/lib/authorization.rb')

class SampleUser
  include Authorization
  attr_accessor :roles_mask
  
  def initialize
    roles_mask = 0
  end
end

describe Authorization do
  before(:each) do
    @user = SampleUser.new
  end

  context "persist as bit mask" do
    it "- admin" do
      @user.roles = "admin"
      @user.roles_mask.should == 1
      @user.roles = :admin
      @user.roles_mask.should == 1
    end
    
    it "- organizer" do
      @user.roles = "organizer"
      @user.roles_mask.should == 2
      @user.roles = :organizer
      @user.roles_mask.should == 2
    end
    
    it "- multiple" do
      @user.roles = ["admin", "organizer"]
      @user.roles_mask.should == 3
      @user.roles = [:admin, :organizer]
      @user.roles_mask.should == 3
    end
    
    it "- none" do
      @user.roles = []
      @user.roles_mask.should == 0
    end
    
    it "- invalid is ignored" do
      @user.roles = "invalid"
      @user.roles_mask.should == 0
      @user.roles = :invalid
      @user.roles_mask.should == 0
    end
    
    it "- mixed valid and invalid (ignores invalid)" do
      @user.roles = ["invalid", "organizer", "admin"]
      @user.roles_mask.should == 3
      @user.roles = [:invalid, :organizer, :admin]
      @user.roles_mask.should == 3
    end
  end

  context "attribute reader for roles" do
    it "- no roles" do
      @user.roles.should be_empty
    end

    it "- single role" do
      @user.roles = "admin"
      @user.roles.should == ["admin"]

      @user.roles = "organizer"
      @user.roles.should == ["organizer"]
    end
    
    it "- multiple roles" do
      @user.roles = ["admin", "organizer"]
      @user.roles.should include("admin")
      @user.roles.should include("organizer")
    end
  end
  
  context "defining boolean methods for roles" do
    it "- admin" do
      @user.should_not be_admin
      @user.roles = "admin"
      @user.should be_admin
    end
    
    it "- organizer" do
      @user.should_not be_organizer
      @user.roles = "organizer"
      @user.should be_organizer
    end
    
    it "- multiple" do
      @user.roles = ["admin", "organizer"]
      @user.should_not be_guest
      @user.should be_admin
      @user.should be_organizer
    end
    
    it "- none (guest)" do
      @user.roles = []
      @user.should be_guest
      @user.should_not be_admin
      @user.should_not be_organizer
    end    
  end
  
  context "adding a role" do
    it "- string" do
      @user.add_role "admin"
      @user.should be_admin
    end
    
    it "- symbol" do
      @user.add_role :admin
      @user.should be_admin
    end
    
    it "- invalid" do
      @user.add_role :invalid
      @user.roles_mask.should == 0
    end
    
    it "- multiple roles" do
      @user.roles = [:admin, :organizer]
      @user.add_role :organizer
      @user.should be_admin
      @user.should be_organizer
    end
  end

  context "removing a role" do
    before(:each) do
      @user.add_role "admin"
    end
    
    it "- string" do
      @user.remove_role "admin"
      @user.should_not be_admin
    end
    
    it "- symbol" do
      @user.remove_role :admin
      @user.should_not be_admin
    end
    
    it "- invalid" do
      @user.remove_role :invalid
      @user.roles_mask.should == 1
    end
    
    it "- multiple roles" do
      @user.add_role :organizer
      @user.should be_admin
      @user.should be_organizer
      
      @user.remove_role "organizer"
      @user.remove_role :admin
      @user.should_not be_admin
      @user.should_not be_organizer
    end
  end
end
