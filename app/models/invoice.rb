class Invoice < ActiveRecord::Base

  belongs_to :attendance
  belongs_to :registration_group

  delegate :email, :full_name, :cpf, :gender, :phone, :address, :neighbourhood, :city, :state, :zipcode, to: :attendance

  def self.from_attendance(attendance)
    Invoice.create!(attendance: attendance)
  end

  def self.from_registration_group(group)
    Invoice.create!(registration_group: group)
  end
end
