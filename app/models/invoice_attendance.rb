# encoding: UTF-8
class InvoiceAttendance < ActiveRecord::Base
  belongs_to :attendance
  belongs_to :invoice
end
