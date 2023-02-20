class Product < ApplicationRecord

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
    :price,
    :discogs_price,
    :discogs_id,
    :ebay_price,
    :ebay_id,
    :master_id,
    :cost_price,
    :buying_date,
    :registration_date,
    :quantity,
    :youtube,
    :sold_date,
    :sold_price,
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
        :price,
        :discogs_price,
        :discogs_id,
        :ebay_price,
        :ebay_id,
        :master_id,
        :cost_price,
        :buying_date,
        :registration_date,
        :quantity,
        :youtube,
        :sold_date,
        :sold_price,
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
end
