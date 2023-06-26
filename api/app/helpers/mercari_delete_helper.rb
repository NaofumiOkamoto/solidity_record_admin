module MercariDeleteHelper
  def mercari_delete_header
    [
      'SKU',
    ]
  end

  def mercari_delete_format(sold_products, _)
    sold_products.pluck(:SKU).map{ |sku| [sku] }
  end
end