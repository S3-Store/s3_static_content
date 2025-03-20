# frozen_string_literal: true

class CreateSpreeBlogsTaxons < ActiveRecord::Migration[7.2]
  def change
    create_table :spree_blogs_taxons do |t|
      t.integer :blog_id
      t.integer :taxon_id
      t.integer :position
      t.timestamps
    end
    add_index :spree_blogs_taxons, :blog_id
    add_index :spree_blogs_taxons, :taxon_id
    add_index :spree_blogs_taxons, :position
  end
end
