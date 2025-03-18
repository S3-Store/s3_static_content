# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Admin Static Content', js: true do
  stub_authorization!

  before do
    create :store, default: true
  end

  context 'when no page exists' do
    before do
      visit spree.admin_path
      click_link 'Pages'
    end

    it 'can create new page' do
      expect(page).to have_text /No Pages found/i

      click_link 'New page'

      expect(page).to have_text 'New page'

      fill_in 'page_title', with: 'Contact us'
      fill_in 'page_slug', with: 'contact-us'
      fill_in 'page_body', with: 'hello..'

      fill_in 'page_meta_title', with: 'Contact us'
      fill_in 'page_meta_keywords', with: 'spree, contact'
      fill_in 'page_meta_description', with: 'Short description for contact page.'

      check 'page_show_in_sidebar'
      check 'page_show_in_header'
      check 'page_show_in_footer'

      expect(find_by_id('page_visible')).to be_checked

      click_button 'Create'
      expect(page).to have_text 'successfully created!'
    end
  end

  context 'when page exists' do
    let!(:static_page) { create(:page) }

    before do
      visit spree.admin_path
      click_link 'Pages'
    end

    it 'can be updated' do
      within_row(1) do
        click_icon :edit
      end

      fill_in 'page_title', with: 'Contact'
      fill_in 'page_slug', with: 'contact'

      scroll_to find_button('Update')
      click_button 'Update'
      expect(page).to have_text 'successfully updated!'
    end

    it 'can be deleted' do
      within_row(1) do
        accept_confirm { click_icon :trash }
      end

      expect(page).not_to have_text static_page.title
    end
  end
end
