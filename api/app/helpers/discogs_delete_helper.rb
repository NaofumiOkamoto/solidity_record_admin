module DiscogsDeleteHelper
  require 'discogs'

  def discogs_delete_header
    [
      'listing_id',
    ]
  end

  def discogs_delete_format(products)
    p products.pluck(:SKU, :sold_date)
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

    p "discogsに登録されている商品数: #{search.pagination.items.to_f}"
    (2..(search.pagination.items.to_f / 100.0).ceil).each do |t|
      p t
      result = auth_wrapper.get_user_inventory("solidityrecords",
        :sort => 'listed',
        :sort_order => 'desc',
        :page => t,
        :per_page => 100
      )
      listings += result.listings
    end

    delete_release_ids = products.pluck(:discogs_release_id)
    delete_listing_ids = []
    test_array = []
    listings.each do |l|
      if delete_release_ids.include?(l.release.id)
        delete_listing_ids << l.id
      end
      test_array << l.release.id
    end

    delete_listing_ids
  end

  private

end