# frozen_string_literal: true

class CreateBlogs < ActiveRecord::Migration[7.2]
  def change
    create_table :spree_blogs do |t|
      t.integer :status, default: 0, null: false, comment: '0 is draft, 1 is publish'
      t.string :slug
      t.string :title
      t.string :subtitle
      t.string :author
      t.datetime :publishing_date
      t.text :content
      t.integer :position, default: 0
      t.references :primary_taxon, type: :integer, foreign_key: { to_table: :spree_taxons }

      t.timestamps
    end

    add_index :spree_blogs, :slug, unique: true
    add_index :spree_blogs, :position
  end
end
