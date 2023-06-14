module MercariDeleteHelper
  def mercari_delete_header
    [
      'SKU',
    ]
  end

  def mercari_delete_format(products)
    products.pluck(:SKU)
  end
end