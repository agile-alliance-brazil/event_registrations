# frozen_string_literal: true

class AddPrivacyPolicyLinkToEvent < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :privacy_policy, :string, null: true
  end
end
