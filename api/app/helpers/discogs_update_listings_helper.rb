module DiscogsUpdateListingsHelper
  require 'discogs'

  def discogs_update_listings
    auth_wrapper = Discogs::Wrapper.new(
      "solidityrecords", user_token: "liQrPFTmGUPoCNAtXHmwAbJPpcMpIDYhBmpqsiQR"
      )
    search = auth_wrapper.get_user_inventory("solidityrecords",
      :sort => 'listed',
      :sort_order => 'desc',
      :page => 1,
      :per_page => 100
    )
    listings = search.listings

    listings.each do |listing|
      product = Product.find_by(discogs_release_id: listing.release.id)
      if product
        product.update(discogs_listing_id: listing.id)
      end
    end
  end
end