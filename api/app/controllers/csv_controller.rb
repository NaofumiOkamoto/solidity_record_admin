class CsvController < ApplicationController
  require 'csv'

  def index
    render :json => {id: 1}
  end

  def new
    Rails.logger.level = 1

    # 本番シート
    result = GoogleApi::Spreadsheets.new.get_values(ENV['PRODUCT_SHEET'], ["products!A:AQ"])
    genre = GoogleApi::Spreadsheets.new.get_values(ENV['GENRE_SHEET'], ["genre!B:D"])
    Rails.logger.info('スプシ取得完了')

    genre_map = {}
    genre.values.each do |g|
      next if g[0] == 'id'
      genre_map[g[0]] = { main: g[1], sub: g[2] }
    end

    # テストシート
    # result = GoogleApi::Spreadsheets.new.get_values(ENV['PRODUCT_TEST_SHEET'], ["products_test!A:AQ"])

    if result.values[0] != Product::SP_HEADER
      raise ActionController::BadRequest.new("スプレットシートのヘッダーが正しくありません")
    end

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

    # format の絞り込み
    if params[:platform] == 'mercari'
      products = products.where(format: '7 inch')
    end
    Rails.logger.info('format絞り込み完了')

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
    csv_data = CSV.generate do |csv|
      platform = params[:platform]
      header = self.send("#{platform}_header")
      csv << header
      products.each do |value|
        line = self.send("#{platform}_format", value, genre_map)
        csv << line if line.length > 0
      end
    end
    send_data(csv_data, filename: "test.csv")
  end

end
