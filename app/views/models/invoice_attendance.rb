# encoding: UTF-8
# == Schema Information
#
# Table name: invoice_attendances
#
#  id            :integer          not null, primary key
#  invoice_id    :integer
#  attendance_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class InvoiceAttendance < ActiveRecord::Base
  belongs_to :attendance
  belongs_to :invoice
end