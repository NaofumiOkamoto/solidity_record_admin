class CsvController < ApplicationController
  require 'csv'


  def index
    render :json => {id: 1}
  end

  def new
    # result = GoogleApi::Spreadsheets.new.get_values("13M4gepsCBG9RteGwxjnJII7VixjGteLZ_k0GhmUHM_g", ["products!A:AP"])
    # result = GoogleApi::Spreadsheets.new.get_values("1JZ9YJOM04QimTdW6zyjHXWL9WUemkee-1L7oEanUG7A", ["products_test!A:AP"])
    result_values = [
      ["SKU", "artist", "title", "label", "country", "number", "release_year", "recoding_date", "genre", "format", "barcode", "track_list", "personnel", "musical_instrument", "item_condition", "cover_grading", "cover_description", "shopify用mp3_A", "shopify用mp3_B", "yahoo用mp3_A", "yahoo用mp3_B", "record_description_jp", "record_description_en", "record_grading", "weight", "price", "discogs_price", "discogs_id", "ebay_price", "ebay_id", "master_id", "cost_price", "buying_date", "registration_date", "quantity", "youtube", "img_count", "sold_date", "sold_price", "product_status", "sales_status", "ishii_memo"],
      ["1", "Hank Mobleyyy", "Soul Station", "Blue Note", "Japan", "GXK 8096", "1978", "1960/02/07", "103_105", "LP", "NULL", "A1. Remember A2. This I Dig Of You A3. Dig Dis B1. Split Feelin's B2. Soul Station B3. If I Should Lose You", "Hank Mobley (ts), Paul Chambers (b), Art Blakey (ds), Wynton Kelly (p)", "Tenor Saxophone", "Used", "EX-", "with insert and OBI. some brown stains.", "", "", "", "", "", "close to NM. great shape.", "EX+", "300", "7980", "80", "15531107", "79.99", "NULL", "1", "", "", "NULL", "0", "https://youtu.be/sbmKLZ_opuQ", "5", "NULL", "", "Active", "Sold Out"],
      ["2", "Miles Davissss", "Bags Groove", "Prestige", "Japan", "SMJ-6520", "1976", "1954/06/29_1954/12/24", "103_105", "LP", "NULL", "A1. Bags' Groove (Take 1) A2. Bags' Groove (Take 2) B1. Airegin B2. Oleo B3. But Not For Me (Take 2) B4. Doxy B5. But Not For Me (Take 1)", "Miles Davis (tp), Percy Heath (b), Kenny Clarke (ds), Horace Silver, Thelonious Monk (p), Sonny Rollins (ts), Milt Jackson (vib)", "Trumpet", "Used", "EX", "with insert and OBI.", "", "", "", "", "", "close to NM. great shape.", "EX+", "300", "3980", "40", "3696756", "39.99", "NULL", "2", "", "", "NULL", "0", "https://youtu.be/lF74qucsaWY", "5", "NULL", "", "Active", "Sold Out"],
      ["3", "James Brown", "James Brown", "Polydor", "Japan", "MP9381/2", "1970", "1969/01/01_1970/12/31", "2", "2LP", "NULL", "", "", "NULL", "Used", "", "", "", "", "", "", "", "", "", "", "3980", "", "1117", "", "", "3", "", "", "NULL", "1", "https://youtu.be/4d6uuYc_l74", "5", "NULL", "", "Active"],
      ["4", "Count Basie And His Orchestra", "Warm Breeze", "Pablo Today", "Japan", "28MJ3108", "1982", "1978/07/16", "103", "LP", "NULL", "", "", "NULL", "Used", "", "", "", "", "", "", "", "", "", "", "NULL", "", "1113", "", "", "4", "", "", "NULL", "1", "NULL", "5", "NULL"],
      ["5", "Mari Nakamoto_Tatsuya Takahashi & Tokyo Union", "Montreux The Best '78", "Zen", "Japan", "ZEN1004", "1978", "July 16, 1978", "109", "LP", "NULL", "", "", "NULL", "Used", "", "", "", "", "", "", "", "", "", "", "0", "", "1115", "", "", "5", "", "", "NULL", "1", "NULL", "5", "NULL"], 
      ["6", "Various", "Spiritual Jazz Vol. 11: SteepleChase", "Jazzman", "UK", "JMANLP120", "2020", "NULL", "113", "2LP", "NULL", "", "", "NULL", "New", "", "", "", "", "", "", "", "", "", "", "3980", "", "1114", "", "", "6", "", "", "NULL", "1", "https://youtu.be/9yfqBhxqwZA", "1", "NULL"]
    ]

    Product.new.spreadsheets_save(result_values)

    # TODO Productからcsv用データを作成する（フィルタも含め）
    result = Product.all

    # これはスプしの情報をそのままcsvにする方法
    # result = []
    # keys = result_values[0]
    # keys_length = keys.length
    # result_values.each_with_index do |h,i|
    #   # ヘッダーは処理しない
    #   next if i == 0
    #   # 配列の要素数を合わせる
    #   array = Array.new(keys_length - h.length)
    #   h.concat array
    #   # ヘッダーをkey, 値をvalueの形に直す
    #   ary = [keys, h].transpose
    #   result << Hash[*ary.flatten]
    # end

    respond_to do |format|
      format.html
      format.csv do |csv|
        send_posts_csv(result)
      end
    end
  end

  private

  def send_posts_csv(result_values)
    discogs_header = [
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
    csv_data = CSV.generate do |csv|
      csv << discogs_header
      result_values.each do |value|
        line = discogs_format(value)
        csv << line if line.length > 0
      end
    end
    send_data(csv_data, filename: "test.csv")
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
