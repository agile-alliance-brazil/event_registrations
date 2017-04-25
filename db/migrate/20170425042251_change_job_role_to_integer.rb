class ChangeJobRoleToInteger < ActiveRecord::Migration[5.0]
  def change
    remove_column :attendances, :job_role, :string
    add_column :attendances, :job_role, :integer, default: 0
  end
end
