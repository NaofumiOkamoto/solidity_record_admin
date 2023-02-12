class CsvController < ApplicationController
  require 'csv'

  def index
    render :json => {id: 1}
  end

  def new
    # result = GoogleApi::Spreadsheets.new.get_values(ENV['PRODUCT_SHEET'], ["products!A:AP"])
    # result = GoogleApi::Spreadsheets.new.get_values(ENV['PRODUCT_TEST_SHEET'], ["products_test!A:AP"])
    spreadsheet_result_values = [
      ["SKU", "artist", "title", "label", "country", "number", "release_year", "recoding_date", "genre", "format", "barcode", "track_list", "personnel", "musical_instrument", "item_condition", "cover_grading", "cover_description", "shopify用mp3_A", "shopify用mp3_B", "yahoo用mp3_A", "yahoo用mp3_B", "record_description_jp", "record_description_en", "record_grading", "weight", "price", "discogs_price", "discogs_id", "ebay_price", "ebay_id", "master_id", "cost_price", "buying_date", "registration_date", "quantity", "youtube", "img_count", "sold_date", "sold_price", "product_status", "sales_status", "ishii_memo"],
      ["1", "Hank Moble", "Soul Station", "Blue Note", "Japan", "GXK 8096", "1978", "1960/02/07", "103_105", "LP", "NULL", "A1. Remember A2. This I Dig Of You A3. Dig Dis B1. Split Feelin's B2. Soul Station B3. If I Should Lose You", "Hank Mobley (ts), Paul Chambers (b), Art Blakey (ds), Wynton Kelly (p)", "Tenor Saxophone", "Used", "EX-", "with insert and OBI. some brown stains.", "", "", "", "close to NM. great shape.", "EX+", "300", "7980", "80", "15531107", "79.99", "NULL", "1", "", "", "NULL", "0", "https://youtu.be/sbmKLZ_opuQ", "5", "NULL", "", "Active", "Sold Out"],
      ["2", "Miles Davissss", "Bags Groove", "Prestige", "Japan", "SMJ-6520", "1976", "1954/06/29_1954/12/24", "103_105", "LP", "NULL", "A1. Bags' Groove (Take 1) A2. Bags' Groove (Take 2) B1. Airegin B2. Oleo B3. But Not For Me (Take 2) B4. Doxy B5. But Not For Me (Take 1)", "Miles Davis (tp), Percy Heath (b), Kenny Clarke (ds), Horace Silver, Thelonious Monk (p), Sonny Rollins (ts), Milt Jackson (vib)", "Trumpet", "Used", "EX", "with insert and OBI.", "", "", "", "close to NM. great shape.", "EX+", "300", "3980", "40", "3696756", "39.99", "NULL", "2", "", "", "NULL", "0", "https://youtu.be/lF74qucsaWY", "5", "NULL", "", "Active", "Sold Out"],
      # ["3", "James Brown", "James Brown", "Polydor", "Japan", "MP9381/2", "1970", "1969/01/01_1970/12/31", "2", "2LP", "NULL", "", "", "NULL", "Used", "", "", "", "", "", "", "", "", "3980", "", "1117", "", "", "3", "", "", "NULL", "1", "https://youtu.be/4d6uuYc_l74", "5", "NULL", "", "Active"],
      # ["4", "Count Basie And His Orchestra", "Warm Breeze", "Pablo Today", "Japan", "28MJ3108", "1982", "1978/07/16", "103", "LP", "NULL", "", "", "NULL", "Used", "", "", "", "", "", "", "", "", "NULL", "", "1113", "", "", "4", "", "", "NULL", "1", "NULL", "5", "NULL"],
      # ["5", "Mari Nakamoto_Tatsuya Takahashi & Tokyo Union", "Montreux The Best '78", "Zen", "Japan", "ZEN1004", "1978", "July 16, 1978", "109", "LP", "NULL", "", "", "NULL", "Used", "", "", "", "", "", "", "", "", "0", "", "1115", "", "", "5", "", "", "NULL", "1", "NULL", "5", "NULL"], 
      # ["6", "Various", "Spiritual Jazz Vol. 11: SteepleChase", "Jazzman", "UK", "JMANLP120", "2020", "NULL", "113", "2LP", "NULL", "", "", "NULL", "New", "", "", "", "", "", "", "", "", "3980", "", "1114", "", "", "6", "", "", "NULL", "1", "https://youtu.be/9yfqBhxqwZA", "1", "NULL"],
      ["127", "Bobby Enriquez_Richie Cole", "\"The Wildman\" Meets \"The Madman\"", "GNP Crescendo", "Japan", "K26P 6146", "1982", "1981", "103_106", "LP", "NULL", "", "", "Piano", "Used", "EX", "with insert and OBI.", "", "", "", "close to NM.great shape and sound.", "EX+", "300", "1480", "15", "5729199", "", "", "127", "", "", "2021/04/15", "", "", "5", "NULL", "", "Active", "In Stock"], 
      ["133", "Marian McPartland", "Plays Music Of Leonard Bernstein", "Time", "Japan", "ULS-1760-BT", "1975", "1960/09/28", "103_107", "LP", "NULL", "", "", "Piano", "Used", "EX", "with insert and OBI. OBI has slight discolored.", "", "", "", "close to NM.great shape and sound.", "EX+", "300", "2980", "30", "13379092", "", "", "133", "", "", "2021/04/15", "", "", "5", "NULL", "", "Active", "In Stock"], 
      ["151", "Keith Jarrett", "Ruta And Daitya", "ECM", "Japan", "PAP-25520", "1981", "1971", "103_106", "LP", "NULL", "", "", "Piano", "Used", "EX-", "with insert and OBI. OBI has slight damage.", "", "", "", "close to NM. great shape and sound.", "EX+", "300", "2980", "30", "11942423", "", "", "151", "", "", "2021/04/18", "", "", "5", "NULL", "", "Active", "In Stock"], 
      ["162", "Kenny Drew", "Ruby My Dear", "SteepleChase", "Japan", "RJ-7498", "NULL", "1977/08/23", "112", "LP", "NULL", "", "", "Piano", "Used", "EX-", "with insert and OBI.", "", "", "", "close to NM.great shape and sound.", "EX+", "300", "1980", "20", "7768006", "", "", "162", "", "", "2021/04/15", "", "", "5", "NULL", "", "Active", "In Stock"], 
      ["178", "Miles Davis", "Sketches Of Spain", "CBS/Sony", "Japan", "SONP 50162", "1969", "1959_1960", "103", "LP", "NULL", "", "", "Trumpet", "Used", "EX-_EX", "with CAP OBI. liner notes is described on back cover. shrink wrap.", "", "", "", "some slight marks. but good shape and sound.", "EX-", "300", "3480", "35", "3842748", "", "", "178", "", "", "2021/04/15", "", "", "", "NULL", "", "Active", "In Stock"], 
      ["185", "Chick Corea", "Piano Improvisations Vol. 1", "Polydor", "Japan", "MPF 1134", "1978", "1971/04/21_1971/04/22", "103_106", "LP", "NULL", "", "", "Piano", "Used", "EX", "with insert and OBI. ", "", "", "", "great shape and sound.", "EX", "300", "1980", "20", "4574265", "", "", "185", "", "", "2021/04/18", "", "", "", "NULL", "", "Active", "In Stock"], 
      ["197", "Herbie Hancock", "Dedication", "CBS/Sony", "Japan", "18AP 2180", "1981", "1974/07/29", "112", "LP", "NULL", "", "", "Piano", "Used", "EX-", "with insert and CAP OBI. some brown stains. shrink wrap.", "", "", "", "close to NM. great shape and sound.", "EX+", "300", "6980", "70", "5906807", "", "", "197", "", "", "2021/04/18", "", "", "", "NULL", "", "Active", "In Stock"], 
      ["204", "Stanley Cowell", "Illusion Suite", "ECM", "Japan", "PAP-25524", "NULL", "1972/11/29", "112", "7inchi", "NULL", "", "", "Piano", "Used", "VG+_EX-", "with insert and OBI. some brown stains.", "", "", "", "close to NM.great shape and sound.", "EX+", "300", "2980", "30", "16251925", "", "", "204", "", "", "2021/04/15", "", "", "", "NULL", "", "Active", "In Stock"]
    ]

    # productテーブルに一旦保存する

    # 開発段階だと下記を使用する
    Product.new.spreadsheets_to_db_save(spreadsheet_result_values)

    # スプしから取得した場合は下記を使用する
    # Product.new.spreadsheets_to_db_save(result.values)

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

end
