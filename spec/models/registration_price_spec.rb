# encoding: UTF-8
# == Schema Information
#
# Table name: registration_prices
#
#  id                     :integer          not null, primary key
#  registration_type_id   :integer
#  registration_period_id :integer
#  value                  :decimal(, )
#  created_at             :datetime
#  updated_at             :datetime
#  registration_quota_id  :integer
#

require 'spec_helper'

describe RegistrationPrice, type: :model do
  context 'associations' do
    it { should belong_to :registration_type }
    it { should belong_to :registration_period }
  end
end
