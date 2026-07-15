class CreateProfileTags < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_tags do |t|
      t.integer :profile_id, null: false
      t.integer :tag_id, null: false
      t.integer :writer_id

      t.timestamps null: false
    end
  end
end
