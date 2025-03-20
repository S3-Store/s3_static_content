# frozen_string_literal: true

class CreateJoinTableBlogsStores < ActiveRecord::Migration[7.2]
  def change
    create_table :spree_blogs_stores, id: false do |t|
      t.integer :blog_id, null: false
      t.integer :store_id, null: false
      t.timestamps
    end

    add_index :spree_blogs_stores, :blog_id
    add_index :spree_blogs_stores, :store_id

    add_foreign_key :spree_blogs_stores, :spree_blogs, column: :blog_id
    add_foreign_key :spree_blogs_stores, :spree_stores, column: :store_id
  end
end
