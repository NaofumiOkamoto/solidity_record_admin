class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products, id: false do |t|

      t.integer :SKU, null: false, primary_key: true
      t.string :artist
      t.string :title
      t.string :label
      t.string :country
      t.string :number
      t.integer :release_year
      t.string :recoding_date
      t.string :genre
      t.string :format
      t.string :pic_url
      t.string :barcode
      t.string :track_list
      t.string :personnel
      t.string :musical_instrument
      t.string :item_condition
      t.string :cover_grading
      t.string :cover_description_en
      t.string :cover_description_jp
      t.string :mp3_A
      t.string :mp3_B
      t.string :record_description_jp
      t.string :record_description_en
      t.string :record_grading
      t.integer :weight
      t.integer :img_count
      t.integer :price_jpy
      t.float :price_usd
      t.integer :discogs_release_id
      t.bigint :discogs_listing_id
      t.float :ebay_price
      t.integer :ebay_id
      t.integer :master_id
      t.string :cost_price
      t.string :buying_date
      t.date :registration_date
      t.integer :quantity
      t.string :youtube_A
      t.string :youtube_B
      t.date :sold_date
      t.string :sold_site
      t.string :product_status
      t.string :sales_status
      t.string :ishii_memo
      t.timestamps
    end
  end
end
