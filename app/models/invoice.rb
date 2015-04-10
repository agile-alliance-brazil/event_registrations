class Invoice < ActiveRecord::Base

  belongs_to :user
  belongs_to :registration_group

  delegate :email, :cpf, :gender, :phone, :address, :neighbourhood, :city, :state, :zipcode, to: :user

  def self.from_attendance(attendance)
    Invoice.create!(user: attendance.user, amount: attendance.registration_fee)
  end

  def self.from_registration_group(group)
    Invoice.create!(registration_group: group, user: group.leader, amount: group.total_price)
  end

  def name
    return user.full_name unless registration_group.present?
    registration_group.name
  end
end
