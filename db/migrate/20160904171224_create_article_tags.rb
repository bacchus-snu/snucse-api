class CreateArticleTags < ActiveRecord::Migration[5.0]
  def change
    create_table :article_tags do |t|
      t.integer :article_id, null: false
      t.integer :tag_id, null: false
      t.integer :writer_id

      t.timestamps null: false
    end
  end
end
