module YahooAuctionDeleteHelper

  def yahoo_auction_delete_header
    [
      'SKU'
    ]
  end

  def yahoo_auction_delete_format(products)
    products.pluck(:SKU)
  end

end