# frozen_string_literal: true

module Spree
  class Blog < Spree::Base
    AUTHOR_IMAGE_TYPE = 'AuthorImage'
    ARTICLE_IMAGE_TYPE = 'ArticleImage'

    extend FriendlyId
    friendly_id :slug_candidates, use: :history

    acts_as_list
    has_and_belongs_to_many :stores, join_table: 'spree_blogs_stores'
    has_many :images, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: "Spree::Image"
    has_many :tags, dependent: :delete_all, inverse_of: :blog
    has_many :taxons, through: :tags, before_remove: :remove_taxon

    belongs_to :primary_taxon, class_name: 'Spree::Taxon', optional: true

    validates :title, :author, :content, :slug, presence: true
    validates :slug, presence: true, uniqueness: { allow_blank: true, case_sensitive: true }

    before_validation :normalize_slug, on: :update
    after_destroy :punch_slug
    after_touch :touch_taxons

    scope :published, -> { where(status: :publish).where('publishing_date <= ?', Time.current) }
    scope :by_store, ->(store) { joins(:stores).where("spree_blogs_stores.store_id = ?", store) }
    scope :ordered_by_position, -> { order(:position) }

    enum :status, { draft: 0, publish: 1 }

    def author_image
      images.find_by(image_type: AUTHOR_IMAGE_TYPE)
    end

    def article_images
      images.where(image_type: ARTICLE_IMAGE_TYPE)
    end

    def attach_author_image(image)
      images.create!(attachment: image, image_type: AUTHOR_IMAGE_TYPE)
    end

    def attach_article_images(attach_images)
      attach_images.each do |image|
        images.create!(attachment: image, image_type: ARTICLE_IMAGE_TYPE)
      end
    end

    private

    def normalize_slug
      self.slug = normalize_friendly_id(slug)
    end

    def punch_slug
      # punch slug with date prefix to allow reuse of original
      update_column :slug, "#{Time.current.to_i}_#{slug}" unless frozen?
    end

    # Try building a slug based on the following fields in increasing order of specificity.
    def slug_candidates
      [
        :title,
        [:title, :author]
      ]
    end

    # Iterate through this product's taxons and taxonomies and touch their timestamps in a batch
    def touch_taxons
      taxons_to_touch = taxons.flat_map(&:self_and_ancestors).uniq
      return if taxons_to_touch.empty?

      Spree::Taxon.where(id: taxons_to_touch.map(&:id)).update_all(updated_at: Time.current)

      taxonomy_ids_to_touch = taxons_to_touch.flat_map(&:taxonomy_id).uniq
      Spree::Taxonomy.where(id: taxonomy_ids_to_touch).update_all(updated_at: Time.current)
    end

    def remove_taxon(taxon)
      removed_tags = tags.where(taxon:)
      removed_tags.each(&:remove_from_list)
    end
  end
end
