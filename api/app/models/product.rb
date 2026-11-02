class Product < ApplicationRecord

  # products.genre は "1_19" のようにジャンル id を "_" で連結して持つ（正本はスプレッドシート）。
  # 解析とクエリをここに集約する。将来 product_genres のような中間テーブルに
  # 正規化するときの差し替え点をこの2つに絞るのが目的。
  #
  # 指定した id を含む商品を引く。
  # "_" は LIKE のワイルドカードなのでエスケープが必須。
  # エスケープしないと "_9_" が任意の3文字に当たり、id=9 が "1_19" に誤ヒットする。
  # 前後に区切り文字を足してから照合するのは、"1" が "110" に当たらないようにするため。
  scope :with_genre, lambda { |id|
    pattern = sanitize_sql_like("_#{id}_")
    where("CONCAT('_', genre, '_') LIKE ?", "%#{pattern}%")
  }

  # "1_19" → [1, 19]。数値でない要素は捨てる
  def self.parse_genre_ids(value)
    value.to_s.split('_').filter_map { |id| id.to_i if id.match?(/\A\d+\z/) }
  end

  def genre_ids
    self.class.parse_genre_ids(genre)
  end

  # 商品詳細（docs/03-product-detail.md）で返す列。
  # 未使用の11項目（99 B-2 で「詳細にも出さない」と確定）とタイムスタンプは返さない。
  DETAIL_COLUMNS = %w[
    SKU discogs_release_id artist title label country number release_year genre format item_condition
    record_grading cover_grading record_description_jp record_description_en
    cover_description_jp cover_description_en mp3_A mp3_B weight img_count
    price_jpy price_usd cost_price quantity registration_date sold_date sold_site sales_status
    recoding_date track_list personnel discogs_listing_id
  ].freeze

  # 管理画面の編集フォームから変えられる列（docs/03-product-detail.md）。
  # SKU は専用の操作で変える（影響が大きいため）。eBay 用の3項目はフォームに載せない（99 B-1）。
  # discogs_listing_id は Discogs API から書き戻す列なので人には触らせない。
  EDITABLE_COLUMNS = (DETAIL_COLUMNS - %w[SKU recoding_date track_list personnel discogs_listing_id]).freeze

  ITEM_CONDITIONS = %w[New Used].freeze

  # 入力チェックは管理画面から保存するときだけ効かせる（valid?(:admin_form)）。
  # 既存データには通らない行があり（artist 空1件、release_year が "197" の4件など。2026-10 時点）、
  # 常に効かせると discogs_update_listings_helper の product.update(discogs_listing_id: ...) が
  # それらの商品で黙って失敗するようになるため。スプレッドシート取込は upsert_all なのでもともと通らない。
  with_options on: :admin_form do
    validates :artist, :title, presence: true
    validates :item_condition, inclusion: { in: ITEM_CONDITIONS }
    validates :price_jpy, :weight, :img_count, :quantity,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :price_usd, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :discogs_release_id, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :release_year,
              numericality: { only_integer: true, greater_than_or_equal_to: 1000, less_than_or_equal_to: 9999 },
              allow_nil: true
    # 文字列の列はすべて varchar(255)
    validates :artist, :title, :label, :country, :number, :genre, :format, :item_condition,
              :record_grading, :cover_grading, :record_description_jp, :record_description_en,
              :cover_description_jp, :cover_description_en, :mp3_A, :mp3_B,
              :cost_price, :sold_site, :sales_status,
              length: { maximum: 255 }
    validate :dates_must_be_parsable
    validate :genre_ids_must_exist
  end

  # 同じ discogs_release_id の商品として並べる列（99 B-6 で確定）
  SAME_RELEASE_COLUMNS = %w[SKU record_grading price_jpy price_usd quantity].freeze

  # 同じ盤（discogs_release_id が同じ）の他の商品。新しい SKU が先。
  # release_id が空か 0 の商品同士は同じ盤ではないので並べない
  def same_release_products
    return Product.none if discogs_release_id.blank? || discogs_release_id.zero?

    Product.where(discogs_release_id: discogs_release_id)
           .where.not(SKU: self.SKU)
           .order(SKU: :desc)
           .select(*SAME_RELEASE_COLUMNS)
  end

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
    valid_rows, skipped_rows = result_values.drop(1).partition { |row| valid_sku?(row) }
    log_skipped_rows(skipped_rows)

    # 大量データ向けの改善: 1000行ずつバッチ処理
    valid_rows.each_slice(1000) do |batch|
      products_attributes = batch.map do |row_data|
        row = Row.new(*row_data)
        row.to_h.slice(
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
      end
      
      Product.upsert_all(products_attributes)
    end
  end

  # CSV の行順は SKU 昇順で固定する。
  #
  # 以前は並び順を指定しておらず、たまたま主キー順（＝SKU昇順）で返っていた。
  # 2026-09 に registration_date / sold_date へインデックスを足したところ、
  # MySQL がそのインデックスを使うようになり「日付ごとにまとまった SKU 昇順」に変わって
  # picking_item の出力順が崩れた。実行計画に依存しないよう明示する。
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

    products.order(:SKU)
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

    products.order(:SKU)
  end

  private

  # 日付として読めない文字列は、型変換で黙って nil になり「未入力」と区別がつかなくなるので、元の値で判定する
  def dates_must_be_parsable
    %w[registration_date sold_date].each do |column|
      raw = read_attribute_before_type_cast(column)
      errors.add(column, :invalid_date) if raw.present? && self[column].nil?
    end
  end

  # genre は "1_19" のような id の連結。マスタに無い id を入れると CSV 出力でジャンルが欠落する
  def genre_ids_must_exist
    return if genre.blank?

    unless genre.match?(/\A\d+(_\d+)*\z/)
      errors.add(:genre, :invalid_genre_format)
      return
    end

    missing = genre_ids - Genre.where(id: genre_ids).pluck(:id)
    errors.add(:genre, :unknown_genre, ids: missing.join(', ')) if missing.any?
  end

  # SKU が数値として入っていない行は取り込まない。
  # 入荷登録の途中（artist, title だけ記入して SKU は未記入）の状態でCSVを出力すると、
  # SKU が NULL のまま INSERT され、AUTO_INCREMENT によって毎回別レコードが作られてしまうため。
  # SKU が記入された時点で正常に upsert されるので、この行を飛ばしてもデータは失われない。
  def valid_sku?(row)
    row.present? && row[0].to_s.strip.match?(/\A\d+\z/)
  end

  def log_skipped_rows(skipped_rows)
    return if skipped_rows.empty?

    blank_rows, invalid_rows = skipped_rows.partition { |row| row.compact.empty? }
    Rails.logger.warn("取込スキップ: 空行 #{blank_rows.size}件 / SKU未記入 #{invalid_rows.size}件")
    invalid_rows.each do |row|
      Rails.logger.warn("  SKU未記入のためスキップ: artist=#{row[1].inspect} title=#{row[2].inspect}")
    end
  end

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
