class ApplicationController < ActionController::API
  # csv出力に必要
  include ActionController::MimeResponds
  include DiscogsHelper
  include DiscogsDeleteHelper
  include MercariHelper
  include MercariDeleteHelper
  include ShopifyHelper
  include EbayHelper
  include YahooHelper
  include YahooAuctionHelper
end
