class AddAllowVotingToEvents < ActiveRecord::Migration
  def change
    add_column :events, :allow_voting, :boolean
  end
end
