class Invoice < ActiveRecord::Base

  belongs_to :attendance
  belongs_to :registration_group

  delegate :email, :cpf, :gender, :phone, :address, :neighbourhood, :city, :state, :zipcode, :registration_type, to: :attendance

  def self.from_attendance(attendance)
    Invoice.create!(attendance: attendance)
  end

  def self.from_registration_group(group)
    Invoice.create!(registration_group: group)
  end

  def amount
    return attendance.registration_fee unless registration_group.present?
    registration_group.total_price
  end

  def name
    return attendance.full_name unless registration_group.present?
    registration_group.name
  end
end
