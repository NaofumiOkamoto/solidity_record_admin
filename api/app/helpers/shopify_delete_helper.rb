module ShopifyDeleteHelper
  def shopify_delete_header
    shopify_header
  end

  def shopify_delete_format(sold_products, genre_map)
    rows = []
    sold_products.each { |value|
      rows << shopify_format(value, genre_map, quantity: 0)
    }

    rows
  end

end