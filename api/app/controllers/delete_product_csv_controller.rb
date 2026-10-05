class DeleteProductCsvController < ApplicationController
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
    # テストシート
    # result = GoogleApi::Spreadsheets.new.get_values(ENV['PRODUCT_TEST_SHEET'], ["products_test!A:AR"])
    label = GoogleApi::Spreadsheets.new.get_values(ENV['LABEL_SHEET'], ["label!A:B"])
    Rails.logger.info('スプシ取得完了')

    # ジャンルマスタは 2026-09 に DB へ移した（管理画面から編集する）。
    # 以前はここで GENRE_SHEET を読んでいた。復旧が必要なら rake genres:import。
    genre_map = Genre.csv_map

    label_map = {}
    label.values.each do |l|
      next if l[0] == 'label'
      label_map[l[0]] = { label: l[0], tag: l[1] }
    end

    if result.values[0] != Product::SP_HEADER
      raise ActionController::BadRequest.new("スプレットシートのヘッダーが正しくありません")
    end

    # productテーブルに一旦保存する
    Product.new.spreadsheets_to_db_save(result.values)
    sold_products = Product.new.delete_csv_filter(params)
    Rails.logger.info('DB情報取得完了')


    respond_to do |format|
      format.html
      format.csv do |csv|
        send_posts_csv(sold_products, genre_map, label_map)
      end
    end
  end

  private

  def send_posts_csv(products, genre_map, label_map)
    platform = params[:platform]
    csv_data = CSV.generate do |csv|
      header = self.send("#{platform}_delete_header")
      csv << header

      result = self.send("#{platform}_delete_format", products, genre_map, label_map)
      result.each do |r|
        if platform == 'shopify'
          r.each do |s|
            csv << s
          end
        else
          csv << r
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
  end

end
