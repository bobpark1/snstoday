class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :user_id
      t.integer :snstype
      t.text :pageid

      t.timestamps null: false
    end
  end
end
