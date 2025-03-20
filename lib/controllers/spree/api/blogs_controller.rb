# frozen_string_literal: true

module Spree
  module Api
    class BlogsController < Spree::Api::BaseController
      respond_to :json

      before_action :find_blog, only: [:show, :update, :destroy]

      def index
        authorize! :read, Spree::Blog
        @blogs = Spree::Blog.includes(:images, :tags)
        respond_with @blogs, include: ['author_image', 'article_images', 'tags']
      end

      def show
        authorize! :read, @blog
        render json: @blog.as_json(methods: [:author_image, :article_images, :tags])
      end

      def create
        authorize! :create, Spree::Blog
        @blog = Spree::Blog.new(blog_params)
        if @blog.save
          render json: @blog.as_json(methods: [:author_image, :article_images, :tags]), status: :created
        else
          render json: @blog.errors, status: :unprocessable_entity
        end
      end

      def update
        authorize! :update, @blog
        if @blog.update(blog_params)
          render json: @blog.as_json(methods: [:author_image, :article_images, :tags]), status: :ok
        else
          render json: @blog.errors, status: :unprocessable_entity
        end
      end

      def destroy
        authorize! :destroy, @blog
        if @blog.destroy
          render json: { message: "Successfully Destroyed", object: @blog }, status: :ok
        else
          invalid_resource!(@blog)
        end
      end

      private

      def find_blog
        @blog = Spree::Blog.friendly.find(params[:id])
      end

      def blog_params
        params.require(:blog).permit(permitted_blog_params)
      end

      def permitted_blog_params
        [:title, :subtitle, :slug, :content, :status, :author, :publishing_date, :primary_taxon_id, { taxon_ids: [] }, { store_ids: [] }]
      end
    end
  end
end
