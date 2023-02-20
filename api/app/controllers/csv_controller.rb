class CsvController < ApplicationController
  require 'csv'

  def index
    render :json => {id: 1}
  end

  def new
    # 本番シート
    result = GoogleApi::Spreadsheets.new.get_values(ENV['PRODUCT_SHEET'], ["products!A:AP"])
    # テストシート
    # result = GoogleApi::Spreadsheets.new.get_values(ENV['PRODUCT_TEST_SHEET'], ["products_test!A:AP"])

    # productテーブルに一旦保存する
    Product.new.spreadsheets_to_db_save(result.values)

    # TODO Productからcsv用データを作成する（フィルタも含め）
    quantity = params[:quantity].to_i
    products = Product.all

    # quantity の絞り込み
    case quantity
    when 0
      products = products.where(quantity: quantity)
    when 1
      products = products.where(quantity: quantity..)
    end

    # registration_date の絞り込み
    products = products.where('registration_date >= ?', params[:date].to_date)


    # format の絞り込み
    if params[:platform] == 'mercari'
      products = products.where(format: '7 inch')
    end
    
    # TODO: country の絞り込み
    
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
