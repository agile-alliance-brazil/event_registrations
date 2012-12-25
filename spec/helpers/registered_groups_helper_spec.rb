# encoding: UTF-8
require 'spec_helper'

describe RegisteredGroupsHelper do
  describe "#registration_group_status_options" do
    it "should return status options for filtering" do
      I18n.with_locale(:en) do
        helper.registration_group_status_options.should include(['All', nil])
        helper.registration_group_status_options.should include(['Incomplete', 'incomplete'])
        helper.registration_group_status_options.should include(['Pending', 'complete'])
        helper.registration_group_status_options.should include(['Payment received', 'paid'])
        helper.registration_group_status_options.should include(['Confirmed', 'confirmed'])
        helper.registration_group_status_options.should have(5).items
      end
    end
  end
end
