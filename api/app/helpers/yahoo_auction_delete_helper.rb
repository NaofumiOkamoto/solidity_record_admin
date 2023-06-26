module YahooAuctionDeleteHelper

  def yahoo_auction_delete_header
    [
      'SKU'
    ]
  end

  def yahoo_auction_delete_format(sold_products, _)
    sold_products.pluck(:SKU).map{ |sku| [sku] }
  end

end