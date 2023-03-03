# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_01_19_002326) do
  create_table "products", primary_key: "SKU", id: :integer, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "artist"
    t.string "title"
    t.string "label"
    t.string "country"
    t.string "number"
    t.integer "release_year"
    t.string "recoding_date"
    t.string "genre"
    t.string "format"
    t.string "tags"
    t.string "barcode"
    t.string "track_list"
    t.string "personnel"
    t.string "musical_instrument"
    t.string "item_condition"
    t.string "cover_grading"
    t.string "cover_description_en"
    t.string "cover_description_jp"
    t.string "mp3_A"
    t.string "mp3_B"
    t.string "record_description_jp"
    t.string "record_description_en"
    t.string "record_grading"
    t.integer "weight"
    t.integer "img_count"
    t.integer "price"
    t.integer "discogs_price"
    t.integer "discogs_release_id"
    t.integer "discogs_listing_id"
    t.decimal "ebay_price", precision: 10
    t.integer "ebay_id"
    t.integer "master_id"
    t.string "cost_price"
    t.string "buying_date"
    t.date "registration_date"
    t.integer "quantity"
    t.string "youtube_A"
    t.string "youtube_B"
    t.string "sold_date"
    t.integer "sold_price"
    t.string "product_status"
    t.string "sales_status"
    t.string "ishii_memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
