class CsvController < ApplicationController
  require 'csv'
  require 'fileutils'
  require 'discogs'

  def index
    render :json => {id: 1}
  end

  def new
    Rails.logger.level = 1

    # 本番シート
    Rails.logger.info('スプレットシート取得開始')
    result = GoogleApi::Spreadsheets.new.get_values(ENV['PRODUCT_SHEET'], ["products!A:AR"])
    # テストシート
    # result = GoogleApi::Spreadsheets.new.get_values(ENV['PRODUCT_TEST_SHEET'], ["products_test!A:AR"])
    genre = GoogleApi::Spreadsheets.new.get_values(ENV['GENRE_SHEET'], ["genre!B:E"])
    Rails.logger.info('スプシ取得完了')

    genre_map = {}
    genre.values.each do |g|
      next if g[0] == 'id'
      genre_map[g[0]] = { main: g[1], sub: g[2], yahoo_path_genre: g[3] }
    end


    if result.values[0] != Product::SP_HEADER
      raise ActionController::BadRequest.new("スプレットシートのヘッダーが正しくありません")
    end

    # スプレットシートの列を変更してもできるようにチャレンジしたが、
    # 絞り込みが難しいことに気づき断念
    # test = result.values.map.with_index do |r, i|
    #   next if i == 0
    #   hash = {}
    #   result.values[0].each.with_index do |v, i|
    #     hash[v] = r[i]
    #   end
    #   hash
    # end

    # productテーブルに一旦保存する
    Product.new.spreadsheets_to_db_save(result.values)

    products = Product.new.csv_filter(params)

    if params[:platform] == 'discogs'
      discogs_update_listings
    end

    respond_to do |format|
      format.html
      format.csv do |csv|
        send_posts_csv(products, genre_map)
      end
    end
  end

  private

  def send_posts_csv(products, genre_map)
    platform = params[:platform]
    csv_data = CSV.generate do |csv|
      header = self.send("#{platform}_header")
      csv << header
      products.each do |value|
        line = self.send("#{platform}_format", value, genre_map)
        case platform
        when 'shopify'
          line.each do |l|
            csv << l
          end
        else
          csv << line
        end
      end
    end
    if File.exist?("./tmp/#{platform}_csv")
      FileUtils.rm_r("./tmp/#{platform}_csv")
    end
    Dir.mkdir("./tmp/#{platform}_csv")
    File.open("./tmp/#{platform}_csv/test.csv", 'w') do |file|
      file.write(csv_data)
    end
    if platform == 'yahoo'
      csv_data = csv_data.encode(Encoding::SHIFT_JIS)
    end

    send_data(csv_data, filename: "test.csv")
  end

end
