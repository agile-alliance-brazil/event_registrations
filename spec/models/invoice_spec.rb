require 'spec_helper'

describe Invoice, type: :model do
  context 'associations' do
    it { should belong_to :attendance }
    it { should belong_to :registration_group }
  end

  describe '.from_attendance' do
    let(:attendance) { FactoryGirl.create :attendance }
    subject(:invoice) { Invoice.from_attendance(attendance) }

    it { expect(invoice.attendance).to eq attendance }
  end

  describe '.from_registration_group' do
    let(:group) { FactoryGirl.create :registration_group }
    subject(:invoice) { Invoice.from_registration_group(group) }

    it { expect(invoice.registration_group).to eq group }
  end
end