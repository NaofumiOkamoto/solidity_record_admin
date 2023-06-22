module MercariDeleteHelper
  def mercari_delete_header
    [
      'SKU',
    ]
  end

  def mercari_delete_format(sold_products)
    [
      sold_products.pluck(:SKU)
    ]
  end
end