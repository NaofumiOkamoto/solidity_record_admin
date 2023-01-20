class Product < ApplicationRecord

  # 行の構造を定義
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
    :cover_description,
    :shopify用mp3_A,
    :shopify用mp3_B,
    :yahoo用mp3_A,
    :yahoo用mp3_B,
    :record_description_jp,
    :record_description_en,
    :record_grading,
    :weight,
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
    :img_count,
    :sold_date,
    :sold_price,
    :product_status,
    :sales_status,
    :ishii_memo
  )

  def spreadsheets_to_db_save(result_values)
    result_values.drop(1).each do |row_data|
      row = Row.new(*row_data)
      attributes = row.to_h.slice(
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
        :cover_description,
        :shopify用mp3_A,
        :shopify用mp3_B,
        :yahoo用mp3_A,
        :yahoo用mp3_B,
        :record_description_jp,
        :record_description_en,
        :record_grading,
        :weight,
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
        :img_count,
        :sold_date,
        :sold_price,
        :product_status,
        :sales_status,
        :ishii_memo
      )
      sku_attributes = row.to_h.slice(:SKU)
      products = Product.find_or_initialize_by(sku_attributes)
      products.update(attributes)
      products.save
    end
  end
end
