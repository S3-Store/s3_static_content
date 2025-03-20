# frozen_string_literal: true

class AddImageTypeToSpreeAssets < ActiveRecord::Migration[7.2]
  def change
    add_column :spree_assets, :image_type, :string
  end
end
