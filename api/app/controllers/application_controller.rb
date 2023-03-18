class ApplicationController < ActionController::API
  # csv出力に必要
  include ActionController::MimeResponds
  include DiscogsHelper
  include MercariHelper
  include ShopifyHelper
  include EbayHelper
end
