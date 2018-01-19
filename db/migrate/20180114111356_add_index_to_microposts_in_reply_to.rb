class AddIndexToMicropostsInReplyTo < ActiveRecord::Migration[5.1]
  def change
    add_index :microposts, :in_reply_to
  end
end
