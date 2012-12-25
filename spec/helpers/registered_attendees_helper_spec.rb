# encoding: UTF-8
require 'spec_helper'

describe RegisteredAttendeesHelper do
  describe "#attendee_status_options" do
    it "should return status options for filtering" do
      I18n.with_locale(:en) do
        helper.attendee_status_options.should include(['All', nil])
        helper.attendee_status_options.should include(['Pending', 'pending'])
        helper.attendee_status_options.should include(['Payment received', 'paid'])
        helper.attendee_status_options.should include(['Confirmed', 'confirmed'])
        helper.attendee_status_options.should have(4).items
      end
    end
  end
end
