module PickingItemDeleteHelper

  def picking_item_delete_header
    [
      'SKU',
      'sold_site',
    ]
  end

  def picking_item_delete_format(sold_products, _)
    sold_products.map do |product|
      [
        product['SKU'],
        product['sold_site'],
      ]
    end
  end

end