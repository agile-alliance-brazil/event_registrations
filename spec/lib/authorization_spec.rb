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

  context 'persist as bit mask' do
    it '- admin' do
      @user.roles = 'admin'
      expect(@user.roles_mask).to eq(1)
      @user.roles = :admin
      expect(@user.roles_mask).to eq(1)
    end

    it '- organizer' do
      @user.roles = 'organizer'
      expect(@user.roles_mask).to eq(2)
      @user.roles = :organizer
      expect(@user.roles_mask).to eq(2)
    end

    it '- multiple' do
      @user.roles = %w(admin organizer)
      expect(@user.roles_mask).to eq(3)
      @user.roles = %i(admin organizer)
      expect(@user.roles_mask).to eq(3)
    end

    it '- none' do
      @user.roles = []
      expect(@user.roles_mask).to eq(0)
    end

    it '- invalid is ignored' do
      @user.roles = 'invalid'
      expect(@user.roles_mask).to eq(0)
      @user.roles = :invalid
      expect(@user.roles_mask).to eq(0)
    end

    it '- mixed valid and invalid (ignores invalid)' do
      @user.roles = %w(invalid organizer admin)
      expect(@user.roles_mask).to eq(3)
      @user.roles = %i(invalid organizer admin)
      expect(@user.roles_mask).to eq(3)
    end
  end

  context 'attribute reader for roles' do
    it '- no roles' do
      expect(@user.roles).to be_empty
    end

    it '- single role' do
      @user.roles = 'admin'
      expect(@user.roles).to eq(['admin'])

      @user.roles = 'organizer'
      expect(@user.roles).to eq(['organizer'])
    end

    it '- multiple roles' do
      @user.roles = %w(admin organizer)
      expect(@user.roles).to include('admin')
      expect(@user.roles).to include('organizer')
    end
  end

  context 'defining boolean methods for roles' do
    it '- admin' do
      expect(@user).not_to be_admin
      @user.roles = 'admin'
      expect(@user).to be_admin
    end

    it '- organizer' do
      expect(@user).not_to be_organizer
      @user.roles = 'organizer'
      expect(@user).to be_organizer
    end

    it '- multiple' do
      @user.roles = %w(admin organizer)
      expect(@user).not_to be_guest
      expect(@user).to be_admin
      expect(@user).to be_organizer
    end

    it '- none (guest)' do
      @user.roles = []
      expect(@user).to be_guest
      expect(@user).not_to be_admin
      expect(@user).not_to be_organizer
    end
  end

  context 'adding a role' do
    it '- string' do
      @user.add_role 'admin'
      expect(@user).to be_admin
    end

    it '- symbol' do
      @user.add_role :admin
      expect(@user).to be_admin
    end

    it '- invalid' do
      @user.add_role :invalid
      expect(@user.roles_mask).to eq(0)
    end

    it '- multiple roles' do
      @user.roles = %i(admin organizer)
      @user.add_role :organizer
      expect(@user).to be_admin
      expect(@user).to be_organizer
    end
  end

  context 'removing a role' do
    before(:each) do
      @user.add_role 'admin'
    end

    it '- string' do
      @user.remove_role 'admin'
      expect(@user).not_to be_admin
    end

    it '- symbol' do
      @user.remove_role :admin
      expect(@user).not_to be_admin
    end

    it '- invalid' do
      @user.remove_role :invalid
      expect(@user.roles_mask).to eq(1)
    end

    it '- multiple roles' do
      @user.add_role :organizer
      expect(@user).to be_admin
      expect(@user).to be_organizer

      @user.remove_role 'organizer'
      @user.remove_role :admin
      expect(@user).not_to be_admin
      expect(@user).not_to be_organizer
    end
  end
end
