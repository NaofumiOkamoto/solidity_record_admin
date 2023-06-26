module YahooDeleteHelper

  def yahoo_delete_header
    [
      'code', # SLU
    ]
  end

  def yahoo_delete_format(sold_products, _)
    sold_products.pluck(:SKU).map { |sku| [sku]}
  end

end