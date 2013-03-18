class AddUserInfoToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances, :first_name, :string
    add_column :attendances, :last_name, :string
    add_column :attendances, :email, :string
    add_column :attendances, :organization, :string
    add_column :attendances, :phone, :string
    add_column :attendances, :country, :string
    add_column :attendances, :state, :string
    add_column :attendances, :city, :string
    add_column :attendances, :badge_name, :string
    add_column :attendances, :cpf, :string
    add_column :attendances, :gender, :string
    add_column :attendances, :twitter_user, :string
    add_column :attendances, :address, :string
    add_column :attendances, :neighbourhood, :string
    add_column :attendances, :zipcode, :string
    Attendance.all.each do |attendance|
      common_attributes = attendance.user.attributes.reject do |attr_name, value|
        attr_name == "created_at" || attr_name == "updated_at" || attr_name == "id" || attr_name == "roles_mask" || attr_name == "default_locale"
      end
      attendance.update_attributes!(common_attributes)
    end
  end
end
