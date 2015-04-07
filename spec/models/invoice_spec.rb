require 'spec_helper'

describe Invoice, type: :model do
  context 'associations' do
    it { should belong_to :attendance }
    it { should belong_to :registration_group }

  end
end