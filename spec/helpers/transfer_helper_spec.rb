# encoding: UTF-8

require 'spec_helper'

describe TransferHelper, type: :helper do
  describe 'attendance_as_select' do
    it 'should map attendance to full name prepended with id' do
      attendance = FactoryGirl.build(:attendance, first_name: 'John', last_name: 'Doe')
      attendance.id = 8

      expect(attendance_as_select([attendance])).to eq('8 - John Doe' => 8)
    end

    it 'should all attendances to full name prepended with id' do
      attendance = FactoryGirl.build(:attendance, first_name: 'John', last_name: 'Doe')
      attendance.id = 8
      other_attendance = FactoryGirl.build(:attendance, first_name: 'Mary', last_name: 'Doe')
      other_attendance.id = 45

      select = attendance_as_select([attendance, other_attendance])
      expect(select).to eq('8 - John Doe' => 8, '45 - Mary Doe' => 45)
    end
  end
end
