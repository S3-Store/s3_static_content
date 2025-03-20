# frozen_string_literal: true

module Spree
  module Admin
    class BlogsController < Spree::Admin::ResourceController
      before_action :split_params, only: [:create, :update]

      def delete_image
        image = @blog.images.find(params[:image_id])
        image.destroy!
        redirect_to edit_admin_blog_path(@blog)
      end

      # Override the default create and update method to call attach_image on save/update
      # This is necessary because the image is uploaded via a nested form
      def update
        invoke_callbacks(:update, :before)
        if @object.update(permitted_resource_params)
          invoke_callbacks(:update, :after)
          attach_images
          respond_with(@object) do |format|
            format.html do
              flash[:success] = flash_message_for(@object, :successfully_updated)
              redirect_to location_after_save
            end
            format.js { render layout: false }
          end
        else
          invoke_callbacks(:update, :fails)
          respond_with(@object) do |format|
            format.html do
              flash.now[:error] = @object.errors.full_messages.join(", ")
              render_after_update_error
            end
            format.js { render layout: false }
          end
        end
      end

      def create
        invoke_callbacks(:create, :before)
        @object.attributes = permitted_resource_params
        if @object.save
          invoke_callbacks(:create, :after)
          attach_images
          flash[:success] = flash_message_for(@object, :successfully_created)
          respond_with(@object) do |format|
            format.html { redirect_to location_after_save }
            format.js   { render layout: false }
          end
        else
          invoke_callbacks(:create, :fails)
          respond_with(@object) do |format|
            format.html do
              flash.now[:error] = @object.errors.full_messages.join(", ")
              render_after_create_error
            end
            format.js { render layout: false }
          end
        end
      end

      private

      def find_resource
        Spree::Blog.friendly.find(params[:id])
      end

      def split_params
        return if params[:blog][:taxon_ids].blank?

        params[:blog][:taxon_ids] = params[:blog][:taxon_ids].split(',')
      end

      # Set some default attributes
      def build_resource
        super.tap do |resource|
          if resource.stores.blank?
            resource.stores << Spree::Store.default
          end
        end
      end

      def collection
        super.ordered_by_position
      end

      def attach_images
        if params[:blog][:author_image].present?
          @blog.images.where(image_type: 'AuthorImage').destroy_all
          @blog.attach_author_image(params[:blog][:author_image])
        end

        return if params[:blog][:article_images].blank?

        valid_images = params[:blog][:article_images].reject(&:blank?)
        @blog.attach_article_images(valid_images)
      end

      # Use the normal permitted blog params without including `attachments`
      def permitted_resource_params
        params.require(:blog).permit(permitted_blog_params)
      end

      def permitted_blog_params
        [:title, :subtitle, :slug, :content, :status, :author, :publishing_date, :primary_taxon_id, { taxon_ids: [] }, { store_ids: [] }]
      end
    end
  end
end
