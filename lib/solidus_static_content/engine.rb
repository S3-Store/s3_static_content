# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusStaticContent
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_static_content'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    if SolidusSupport.api_available?
      paths["app/controllers"] << "lib/controllers"
    end

    initializer 'solidus_static_content.configure_backend' do
      next unless ::Spree::Backend::Config.respond_to?(:menu_items)

      ::Spree::Backend::Config.configure do |config|
        content_menu_item = config.class::MenuItem.new(
          label: :contents,
          icon: 'file-text',
          url: -> { Spree::Core::Engine.routes.url_helpers.admin_pages_path },
          condition: -> { can?(:admin, Spree::Page) || can?(:admin, Spree::Blog) },
          match_path: /contents/
        )
        config.menu_items << content_menu_item

        config.menu_items = config.menu_items.map do |item|
          if item.label.to_sym == :contents
            if item.respond_to?(:children)
              unless item.children.any? { |child| child.label == :pages }
                item.children << config.class::MenuItem.new(
                  label: :pages,
                  url: -> { Spree::Core::Engine.routes.url_helpers.admin_pages_path },
                  condition: -> { can?(:admin, Spree::Page) },
                  match_path: /pages/
                )
              end
              unless item.children.any? { |child| child.label == :blogs }
                item.children << config.class::MenuItem.new(
                  label: :blogs,
                  url: -> { Spree::Core::Engine.routes.url_helpers.admin_blogs_path },
                  condition: -> { can?(:admin, Spree::Blog) },
                  match_path: /blogs/
                )
              end
            else
              item.sections << :pages
              item.sections << :blogs
            end
          end
          item
        end
      end
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')).sort.each do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
