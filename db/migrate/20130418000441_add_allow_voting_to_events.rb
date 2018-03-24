# frozen_string_literal: true

class AddAllowVotingToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :allow_voting, :boolean
  end
end
