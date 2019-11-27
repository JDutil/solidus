# frozen_string_literal: true

require 'spec_helper'

RSpec.feature 'Order Comments', type: :feature, js: true do
  stub_authorization!
  let!(:order) { create(:completed_order_with_totals) }

  before :each do
    # admin = create(:admin_user, password: 'test123', password_confirmation: 'test123')
    # visit spree.admin_path
    # fill_in 'Email', with: admin.email
    # fill_in 'Password', with: 'test123'
    # click_button 'Login'
    # admin
  end

  it "adding comments" do
    visit spree.comments_admin_order_path(order)
    expect(page).to have_text(/No Comments found/i)

    fill_in 'Comment', with: 'A test comment.'
    click_button 'Add Comment'

    expect(page).to have_text(/Comments \(1\)/i) # uppercase < v1.2, sentence case >= v1.3
    expect(page).to have_text('A test comment.')
  end
end
