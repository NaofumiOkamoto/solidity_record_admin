class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|

      t.integer :SKU
      t.string :artist
      t.string :title
      t.string :label
      t.string :country
      t.string :number
      t.integer :release_year
      t.string :recoding_date
      t.string :genre
      t.string :format
      t.string :barcode
      t.string :track_list
      t.string :personnel
      t.string :musical_instrument
      t.string :item_condition
      t.string :cover_grading
      t.string :cover_description
      t.string :shopify用mp3_A
      t.string :shopify用mp3_B
      t.string :yahoo用mp3_A
      t.string :yahoo用mp3_B
      t.string :record_description_jp
      t.string :record_description_en
      t.string :record_grading
      t.integer :weight
      t.integer :price
      t.integer :discogs_price
      t.integer :discogs_id
      t.decimal :ebay_price
      t.string :ebay_id
      t.integer :master_id
      t.string :cost_price
      t.string :buying_date
      t.date :registration_date, null: true
      t.integer :quantity
      t.string :youtube
      t.integer :img_count
      t.string :sold_date
      t.integer :sold_price
      t.string :product_status
      t.string :sales_status
      t.string :ishii_memo
      t.timestamps
    end
  end
end
