# frozen_string_literal: true

module Spree
  class Tag < Spree::Base
    self.table_name = 'spree_blogs_taxons'
    acts_as_list scope: :taxon
    belongs_to :blog, class_name: "Spree::Blog", inverse_of: :tags, touch: true, optional: true
    belongs_to :taxon, class_name: "Spree::Taxon", inverse_of: :tags, touch: true, optional: true

    # For https://github.com/spree/spree/issues/3494
    validates :taxon_id, uniqueness: { scope: :blog_id, message: :already_linked }
  end
end
