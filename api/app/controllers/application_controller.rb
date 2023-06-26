class ApplicationController < ActionController::API
  # csv出力に必要
  include ActionController::MimeResponds
  include DiscogsHelper
  include DiscogsDeleteHelper
  include DiscogsUpdateListingsHelper
  include MercariHelper
  include MercariDeleteHelper
  include ShopifyHelper
  include ShopifyDeleteHelper
  include EbayHelper
  include YahooHelper
  include YahooDeleteHelper
  include YahooAuctionHelper
  include YahooAuctionDeleteHelper
end
