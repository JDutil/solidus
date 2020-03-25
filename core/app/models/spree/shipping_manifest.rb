# frozen_string_literal: true

class Spree::ShippingManifest
  ManifestItem = Struct.new(:line_item, :variant, :quantity, :states)

  def initialize(inventory_units:)
    @inventory_units = inventory_units.to_a
  end

  def for_order(order)
    Spree::ShippingManifest.new(
      inventory_units: @inventory_units.select { |iu| iu.order_id == order.id }
    )
  end

  def items
    # Grouping by the ID means that we don't have to call out to the association accessor
    # This makes the grouping by faster because it results in less SQL cache hits.
    @inventory_units.group_by(&:variant_id).map do |_variant_id, variant_units|
      variant_units.group_by(&:line_item_id).map do |_line_item_id, units|
        states = {}
        units.group_by(&:state).each { |state, iu| states[state] = iu.count }

        line_item = units.first.line_item
        variant = units.first.variant
        ManifestItem.new(line_item, variant, units.length, states)
      end
    end.
    flatten.
    sort! do |item_x, item_y|
      # Sort by Variant ID to ensure manifest items are always returned in a
      # dependable order to help reduce the chance of a deadlock during a
      # manifest restock.
      item_x.variant.id <=> item_y.variant.id
    end
  end
end

ActiveSupport.run_load_hooks('Spree::ShippingManifest', Spree::ShippingManifest)
