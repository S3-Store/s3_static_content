# frozen_string_literal: true

module Spree
  module TaxonDecorator
    def self.prepended(base)
      base.has_many :tags, -> { order(:position) }, dependent: :delete_all, inverse_of: :taxon
    end
  end
end

Spree::Taxon.prepend(Spree::TaxonDecorator)
