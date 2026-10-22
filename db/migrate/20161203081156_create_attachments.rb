class CreateAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.integer :article_id, null: false
      t.integer :uploader_id
      t.string :file
      t.string :key

      t.timestamps null: false
    end
  end
end
