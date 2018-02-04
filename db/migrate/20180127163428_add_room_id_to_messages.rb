class AddRoomIdToMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :room_id, :string
    add_index :messages, [:room_id, :created_at]
  end
end
