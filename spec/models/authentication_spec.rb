# encoding: UTF-8
require 'spec_helper'

describe Authentication do
  context "associations" do
    it { should belong_to :user }
  end

  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :provider }
    it { should allow_mass_assignment_of :uid }
  end

  context "validations" do
    it { should validate_presence_of :provider }
    it { should validate_presence_of :uid }
  end
end