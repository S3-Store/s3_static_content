# frozen_string_literal: true

module SolidusStaticContent
  module PagesInSidebar
    Deface::Override.new(virtual_path: "spree/shared/_sidebar",
      name: "pages_in_sidebar",
      insert_bottom: "#sidebar",
      partial: "spree/static_content/static_content_sidebar",
      disabled: false)
  end
end
