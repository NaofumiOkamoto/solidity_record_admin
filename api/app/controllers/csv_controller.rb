class CsvController < ApplicationController
  require 'csv'


  def index
    render :json => {id: 1}
  end

  def new
    # result = GoogleApi::Spreadsheets.new.get_values("13M4gepsCBG9RteGwxjnJII7VixjGteLZ_k0GhmUHM_g", ["products!A:AP"])
    # result = GoogleApi::Spreadsheets.new.get_values("1JZ9YJOM04QimTdW6zyjHXWL9WUemkee-1L7oEanUG7A", ["products_test!A:AP"])
    spreadsheet_result_values = [
      ["SKU", "artist", "title", "label", "country", "number", "release_year", "recoding_date", "genre", "format", "barcode", "track_list", "personnel", "musical_instrument", "item_condition", "cover_grading", "cover_description", "shopify用mp3_A", "shopify用mp3_B", "yahoo用mp3_A", "yahoo用mp3_B", "record_description_jp", "record_description_en", "record_grading", "weight", "price", "discogs_price", "discogs_id", "ebay_price", "ebay_id", "master_id", "cost_price", "buying_date", "registration_date", "quantity", "youtube", "img_count", "sold_date", "sold_price", "product_status", "sales_status", "ishii_memo"],
      ["1", "Hank Moble", "Soul Station", "Blue Note", "Japan", "GXK 8096", "1978", "1960/02/07", "103_105", "LP", "NULL", "A1. Remember A2. This I Dig Of You A3. Dig Dis B1. Split Feelin's B2. Soul Station B3. If I Should Lose You", "Hank Mobley (ts), Paul Chambers (b), Art Blakey (ds), Wynton Kelly (p)", "Tenor Saxophone", "Used", "EX-", "with insert and OBI. some brown stains.", "", "", "", "", "", "close to NM. great shape.", "EX+", "300", "7980", "80", "15531107", "79.99", "NULL", "1", "", "", "NULL", "0", "https://youtu.be/sbmKLZ_opuQ", "5", "NULL", "", "Active", "Sold Out"],
      ["2", "Miles Davissss", "Bags Groove", "Prestige", "Japan", "SMJ-6520", "1976", "1954/06/29_1954/12/24", "103_105", "LP", "NULL", "A1. Bags' Groove (Take 1) A2. Bags' Groove (Take 2) B1. Airegin B2. Oleo B3. But Not For Me (Take 2) B4. Doxy B5. But Not For Me (Take 1)", "Miles Davis (tp), Percy Heath (b), Kenny Clarke (ds), Horace Silver, Thelonious Monk (p), Sonny Rollins (ts), Milt Jackson (vib)", "Trumpet", "Used", "EX", "with insert and OBI.", "", "", "", "", "", "close to NM. great shape.", "EX+", "300", "3980", "40", "3696756", "39.99", "NULL", "2", "", "", "NULL", "0", "https://youtu.be/lF74qucsaWY", "5", "NULL", "", "Active", "Sold Out"],
      ["3", "James Brown", "James Brown", "Polydor", "Japan", "MP9381/2", "1970", "1969/01/01_1970/12/31", "2", "2LP", "NULL", "", "", "NULL", "Used", "", "", "", "", "", "", "", "", "", "", "3980", "", "1117", "", "", "3", "", "", "NULL", "1", "https://youtu.be/4d6uuYc_l74", "5", "NULL", "", "Active"],
      ["4", "Count Basie And His Orchestra", "Warm Breeze", "Pablo Today", "Japan", "28MJ3108", "1982", "1978/07/16", "103", "LP", "NULL", "", "", "NULL", "Used", "", "", "", "", "", "", "", "", "", "", "NULL", "", "1113", "", "", "4", "", "", "NULL", "1", "NULL", "5", "NULL"],
      ["5", "Mari Nakamoto_Tatsuya Takahashi & Tokyo Union", "Montreux The Best '78", "Zen", "Japan", "ZEN1004", "1978", "July 16, 1978", "109", "LP", "NULL", "", "", "NULL", "Used", "", "", "", "", "", "", "", "", "", "", "0", "", "1115", "", "", "5", "", "", "NULL", "1", "NULL", "5", "NULL"], 
      ["6", "Various", "Spiritual Jazz Vol. 11: SteepleChase", "Jazzman", "UK", "JMANLP120", "2020", "NULL", "113", "2LP", "NULL", "", "", "NULL", "New", "", "", "", "", "", "", "", "", "", "", "3980", "", "1114", "", "", "6", "", "", "NULL", "1", "https://youtu.be/9yfqBhxqwZA", "1", "NULL"]
    ]

    # productテーブルに一旦保存する
    Product.new.spreadsheets_to_db_save(spreadsheet_result_values)

    # TODO Productからcsv用データを作成する（フィルタも含め）
    products = Product.all
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_posts_csv(products)
      end
    end
  end

  private

  def send_posts_csv(products)
    csv_data = CSV.generate do |csv|
      platform = params[:platform]
      header = self.send("#{platform}_header")
      csv << header
      products.each do |value|
        line = self.send("#{platform}_format", value)
        csv << line if line.length > 0
      end
    end
    send_data(csv_data, filename: "test.csv")
  end

  def shopify_header
    [
      'Handle',
      'Title',
      'Body (HTML)',
      'Vendor',
      'Product Category',
      'Type',
      'Tags',
      'Published',
      'Option1 Name',
      'Option1 Value',
      'Option2 Name',
      'Option2 Value',
      'Option3 Name',
      'Option3 Value',
      'Variant SKU',
      'Variant Grams',
      'Variant Inventory Tracker',
      'Variant Inventory Qty',
      'Variant Inventory Policy',
      'Variant Fulfillment Service',
      'Variant Price',
      'Variant Compare At Price',
      'Variant Requires Shipping',
      'Variant Taxable	',
      'Variant Barcode',
      'Image Src',
      'Image Position',
      'Image Alt Text',
      'Gift Card',
      'SEO Title',
      'SEO Description',
      'Google Shopping / Google Product Category',
      'Google Shopping / Gender',
      'Google Shopping / Age Group',
      'Google Shopping / MPN	',
      'Google Shopping / AdWords Grouping',
      'Google Shopping / AdWords Labels',
      'Google Shopping / Condition',
      'Google Shopping / Custom Product',
      'Google Shopping / Custom Label 0',
      'Google Shopping / Custom Label 1',
      'Google Shopping / Custom Label 2',
      'Google Shopping / Custom Label 3',
      'Google Shopping / Custom Label 4',
      'Variant Image',
      'Variant Weight Unit',
      'Variant Tax Code',
      'Cost per item',
      'Price / Eurozone',
      'Compare At Price / Eurozone	',
      'Price / International',
      'Compare At Price / International',
      'Price / United Kingdom',
      'Compare At Price / United Kingdom',
      'Price / United States',
      'Compare At Price / United States',
      'Status',
    ]
  end
  def shopify_format(value)
    [
      'aaa', # 'Handle',
      'aaa', # 'Title',
      'aaa', # 'Body (HTML)',
      'aaa', # 'Vendor',
      'aaa', # 'Product Category',
      'aaa', # 'Type',
      'aaa', # 'Tags',
      'aaa', # 'Published',
      'aaa', # 'Option1 Name',
      'aaa', # 'Option1 Value',
      'aaa', # 'Option2 Name',
      'aaa', # 'Option2 Value',
      'aaa', # 'Option3 Name',
      'aaa', # 'Option3 Value',
      'aaa', # 'Variant SKU',
      'aaa', # 'Variant Grams',
      'aaa', # 'Variant Inventory Tracker',
      'aaa', # 'Variant Inventory Qty',
      'aaa', # 'Variant Inventory Policy',
      'aaa', # 'Variant Fulfillment Service',
      'aaa', # 'Variant Price',
      'aaa', # 'Variant Compare At Price',
      'aaa', # 'Variant Requires Shipping',
      'aaa', # 'Variant Taxable	',
      'aaa', # 'Variant Barcode',
      'aaa', # 'Image Src',
      'aaa', # 'Image Position',
      'aaa', # 'Image Alt Text',
      'aaa', # 'Gift Card',
      'aaa', # 'SEO Title',
      'aaa', # 'SEO Description',
      'aaa', # 'Google Shopping / Google Product Category',
      'aaa', # 'Google Shopping / Gender',
      'aaa', # 'Google Shopping / Age Group',
      'aaa', # 'Google Shopping / MPN	',
      'aaa', # 'Google Shopping / AdWords Grouping',
      'aaa', # 'Google Shopping / AdWords Labels',
      'aaa', # 'Google Shopping / Condition',
      'aaa', # 'Google Shopping / Custom Product',
      'aaa', # 'Google Shopping / Custom Label 0',
      'aaa', # 'Google Shopping / Custom Label 1',
      'aaa', # 'Google Shopping / Custom Label 2',
      'aaa', # 'Google Shopping / Custom Label 3',
      'aaa', # 'Google Shopping / Custom Label 4',
      'aaa', # 'Variant Image',
      'aaa', # 'Variant Weight Unit',
      'aaa', # 'Variant Tax Code',
      'aaa', # 'Cost per item',
      'aaa', # 'Price / Eurozone',
      'aaa', # 'Compare At Price / Eurozone	',
      'aaa', # 'Price / International',
      'aaa', # 'Compare At Price / International',
      'aaa', # 'Price / United Kingdom',
      'aaa', # 'Compare At Price / United Kingdom',
      'aaa', # 'Price / United States',
      'aaa', # 'Compare At Price / United States',
      'aaa', # 'Status',
    ]
  end

  def discogs_header
    [
      'listing_id',
      'artist',
      'title',
      'label',
      'catno',
      'format',
      'release_id',
      'status',
      'price',
      'listed',
      'comments',
      'media_condition',
      'sleeve_condition',
      'accept_offer',
      'external_id',
      'weight',
      'format_quantity',
      'location',
      'quantity',
    ]
  end

  def discogs_format(value)
    return [] if value['discogs_id'] == '1117'
    [
      '', # listing_id
      value['artist'],
      value['title'],
      value['label'],
      value['number'], # catno
      value['format'],
      value['discogs_id'], # release_id
      value['sales_status'], # status
      value['discogs_price'], # price
      '', # listed
      value['cover_grading'] + ' ' + value['cover_description'], # comments
      '', # media_condition
      '', # sleeve_condition
      '', # accept_offer
      '', # external_id
      value['weight'],
      '', # format_quantity
      '', # location
      '', # quantity
    ]
  end

end
