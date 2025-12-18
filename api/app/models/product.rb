class Product < ApplicationRecord

  SP_HEADER = [
    'SKU',
    'artist',
    'title',
    'label',
    'country',
    'number',
    'release_year',
    'recoding_date',
    'genre',
    'format',
    'pic_url',
    'barcode',
    'track_list',
    'personnel',
    'musical_instrument',
    'item_condition',
    'cover_grading',
    'cover_description_jp',
    'cover_description_en',
    'mp3_A',
    'mp3_B',
    'record_description_jp',
    'record_description_en',
    'record_grading',
    'weight',
    'img_count',
    'price_jpy',
    'price_usd',
    'discogs_release_id',
    'discogs_listing_id',
    'ebay_price',
    'ebay_id',
    'master_id',
    'cost_price',
    'buying_date',
    'registration_date',
    'quantity',
    'youtube_A',
    'youtube_B',
    'sold_date',
    'sold_site',
    'product_status',
    'sales_status',
    'ishii_memo',
  ]
  # 元となるスプレットシートの列の構造を定義
  Row = Struct.new(
    :SKU,
    :artist,
    :title,
    :label,
    :country,
    :number,
    :release_year,
    :recoding_date,
    :genre,
    :format,
    :pic_url,
    :barcode,
    :track_list,
    :personnel,
    :musical_instrument,
    :item_condition,
    :cover_grading,
    :cover_description_jp,
    :cover_description_en,
    :mp3_A,
    :mp3_B,
    :record_description_jp,
    :record_description_en,
    :record_grading,
    :weight,
    :img_count,
    :price_jpy,
    :price_usd,
    :discogs_release_id,
    :discogs_listing_id,
    :ebay_price,
    :ebay_id,
    :master_id,
    :cost_price,
    :buying_date,
    :registration_date,
    :quantity,
    :youtube_A,
    :youtube_B,
    :sold_date,
    :sold_site,
    :product_status,
    :sales_status,
    :ishii_memo
  )

  def spreadsheets_to_db_save(result_values)
    products_attributes = []
    result_values.drop(1).each do |row_data|
      row = Row.new(*row_data)
      products_attributes << row.to_h.slice(
        :SKU,
        :artist,
        :title,
        :label,
        :country,
        :number,
        :release_year,
        :recoding_date,
        :genre,
        :format,
        :pic_url,
        :barcode,
        :track_list,
        :personnel,
        :musical_instrument,
        :item_condition,
        :cover_grading,
        :cover_description_en,
        :cover_description_jp,
        :mp3_A,
        :mp3_B,
        :record_description_jp,
        :record_description_en,
        :record_grading,
        :weight,
        :img_count,
        :price_jpy,
        :price_usd,
        :discogs_release_id,
        # :discogs_listing_id, # NULLで更新したくないためコメントアウト
        :ebay_price,
        :ebay_id,
        :master_id,
        :cost_price,
        :buying_date,
        :registration_date,
        :quantity,
        :youtube_A,
        :youtube_B,
        :sold_date,
        :sold_site,
        :product_status,
        :sales_status,
        :ishii_memo
      )
      # sku_attributes = row.to_h.slice(:SKU)
      # products = Product.find_or_initialize_by(sku_attributes)
      # products.update(attributes)
      # products.save
    end

    Product.upsert_all(products_attributes)
  end

  def csv_filter(params)
    products = Product.all
    Rails.logger.info('DB情報取得完了')
    products = common_filter(products, params)

    # quantity の絞り込み
    quantity = params[:quantity].to_i
    case quantity
    when 0
      products = products.where(quantity: quantity)
    when 1
      products = products.where(quantity: quantity..)
    end
    Rails.logger.info('quantiry絞り込み完了')

    # registration_date の絞り込み
    products = products.where('registration_date >= ?', params[:date].to_date)
    Rails.logger.info('registration_date絞り込み完了')
    Rails.logger.info("取得数: #{products.length}")

    products
  end

  def delete_csv_filter(params)
    products = Product.all
    Rails.logger.info('DB情報取得完了')
    products = common_filter(products, params)

     # 自分のプラットフォーム以外を出力する
    platform = params[:platform]
    if platform == 'yahoo_auction'
      # yahoo_auction, yahoo_auction_2, yahoo_auction_3 などを除外
      products = products.where.not("sold_site LIKE ?", "yahoo_auction%")
    else
      products = products.where.not(sold_site: platform)
    end

    # sold_date の絞り込み
    products = products.where('sold_date >= ?', params[:date].to_date)
    Rails.logger.info('sold_date')
    Rails.logger.info("取得数: #{products.length}")

    products
  end

  private

  def common_filter(products, params)
    # country の絞り込み
    case params['country']
    when 'japan'
      products = products.where(country: 'Japan')
    when 'except_japan'
      products = products.where.not(country: 'Japan')
    end
    Rails.logger.info('country絞り込み完了')

    products
  end
end
