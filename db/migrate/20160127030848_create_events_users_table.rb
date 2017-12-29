class CreateEventsUsersTable < ActiveRecord::Migration[4.2]
  def change
    create_table :events_users, id: false do |t|
      t.belongs_to :event, index: true
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
