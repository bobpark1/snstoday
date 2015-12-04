class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :user_id
      t.integer :snstype
      t.text :pagename
      t.text :pageid
      t.text :postid

      t.timestamps null: false
    end
  end
end
