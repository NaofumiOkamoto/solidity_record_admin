module DiscogsDeleteHelper
  require 'discogs'

  def discogs_delete_header
    [
      'listing_id',
    ]
  end

  def discogs_delete_format(sold_products)
    # auth_wrapper = Discogs::Wrapper.new(
    #   "solidityrecords", user_token: "liQrPFTmGUPoCNAtXHmwAbJPpcMpIDYhBmpqsiQR"
    #   )
    # search = auth_wrapper.get_user_inventory("solidityrecords",
    #   :sort => 'listed',
    #   :sort_order => 'desc',
    #   :page => 1,
    #   :per_page => 100
    # )
    # listings = search.listings

    # p "discogsに登録されている商品数: #{search.pagination.items.to_f}"
    # (2..(search.pagination.items.to_f / 100.0).ceil).each do |t|
    #   p t
    #   result = auth_wrapper.get_user_inventory("solidityrecords",
    #     :sort => 'listed',
    #     :sort_order => 'desc',
    #     :page => t,
    #     :per_page => 100
    #   )
    #   listings += result.listings
    # end

    sold_products.pluck(:discogs_listing_id).compact.map{ |id| [id] }
  end

  private

end