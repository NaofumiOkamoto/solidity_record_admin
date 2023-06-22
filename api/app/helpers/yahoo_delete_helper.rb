module YahooDeleteHelper

  def yahoo_delete_header
    [
      'code', # SLU
      'sub-code', # ブランク
      'quantity', # 0
      'allow-overdraft', # 0
      'stock-close' # 0
    ]
  end

  def yahoo_delete_format(sold_products)
    sold_products.pluck(:SKU).map { |sku| [sku, '', 0, 0, 0]}
  end

end