class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.integer :snstype
      t.text :name
      t.text :pid
      t.text :url

      t.timestamps null: false
    end
  end
end
