class CsvController < ApplicationController
  require 'csv'
  require 'fileutils'

  def index
    render :json => {id: 1}
  end

  def new
    Rails.logger.level = 1

    # 本番シート
    Rails.logger.info('スプレットシート取得開始')
    result = GoogleApi::Spreadsheets.new.get_values(ENV['PRODUCT_SHEET'], ["products!A:AR"])
    genre = GoogleApi::Spreadsheets.new.get_values(ENV['GENRE_SHEET'], ["genre!B:D"])
    Rails.logger.info('スプシ取得完了')

    genre_map = {}
    genre.values.each do |g|
      next if g[0] == 'id'
      genre_map[g[0]] = { main: g[1], sub: g[2] }
    end

    # テストシート
    # result = GoogleApi::Spreadsheets.new.get_values(ENV['PRODUCT_TEST_SHEET'], ["products_test!A:AR"])

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
    products = Product.all
    Rails.logger.info('DB情報取得完了')

    # quantity の絞り込み
    quantity = params[:quantity].to_i
    case quantity
    when 0
      products = products.where(quantity: quantity)
    when 1
      products = products.where(quantity: quantity..)
    end
    Rails.logger.info('quantiry絞り込み完了')

    # country の絞り込み
    case params['country']
    when 'japan'
      products = products.where(country: 'Japan')
    when 'except_japan'
      products = products.where.not(country: 'Japan')
    end
    Rails.logger.info('country絞り込み完了')

    # registration_date の絞り込み
    products = products.where('registration_date >= ?', params[:date].to_date)
    Rails.logger.info('registration_date絞り込み完了')
    Rails.logger.info("取得数: #{products.length}")

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
    send_data(csv_data, filename: "test.csv")
    # send_file("./tmp/#{platform}_csv/test.csv", filename: "test.csv")
  end

end
