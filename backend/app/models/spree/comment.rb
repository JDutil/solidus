# frozen_string_literal: true

class Spree::Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  belongs_to :commentable, polymorphic: true
  belongs_to :comment_type

  default_scope { order('created_at ASC') }

  # custom scope from Juulio
  scope :fraud, -> { joins(:comment_type).where(spree_comment_types: { name: 'Fraud' }) }

  # NOTE: Comments belong to a user
  belongs_to :user
end
