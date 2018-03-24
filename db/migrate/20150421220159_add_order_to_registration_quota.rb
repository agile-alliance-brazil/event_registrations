# frozen_string_literal: true

class AddOrderToRegistrationQuota < ActiveRecord::Migration[4.2]
  def change
    add_column(:registration_quota, :order, :integer)
  end
end
