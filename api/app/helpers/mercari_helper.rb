module MercariHelper

  def mercari_header
    img_count = Product.maximum(:img_count)
    img_array = []
    img_count.times do |i|
      img_array << "商品画像名_#{i + 1}"
    end
    header = [
      '商品名',
      '商品説明',
      'SKU1_在庫数',
      'SKU1_商品管理コード',
      '販売価格',
      'カテゴリID ',
      '商品の状態',
      '配送方法',
      '発送元の地域',
      '発送までの日数',
      '商品ステータス',
    ]
    img_array + header
  end

  def mercari_format(value)
    max_img_count = Product.maximum(:img_count)
    img_row = Array.new(max_img_count)
    img_count = value['img_count']
    img_count.to_i.times do |i|
      img_row[i] = "#{value['SKU']}_#{i + 1}.jpg"
    end
    row = [
      product_name(value), # 商品名
      product_description(value), # 商品説明
      value['quantity'], # SKU1_在庫数
      value['SKU'], # SKU1_商品管理コード
      value['price'] + 185, # 販売価格
      'rQXZaxCTHYJwurBjB687QC', # カテゴリID
      '', # 商品の状態
      '1', # 配送方法
      'jp13', # 発送元の地域
      '1', # 発送までの日数
      '2', # 商品ステータス
    ]
    img_row + row
  end

  private

  def product_name(value)
    "#{value['artist']} SOUL ソウル レコード 7インチ 45"
  end

  def product_description(value)
    record_description_jp = value['record_description_jp'].present? ? "(#{value['record_description_jp']})": ''

    description = <<~PRODUCT
      ●Artist: 

      #{value['artist']}

      ●Title: 

      #{value['title']}

      ●Label: 

      #{value['label']}

      ●Country:

      #{value['country']}

      ●Number: 

      #{value['number']}

      ●Format:

      #{value['format']}

      ●Year:

      #{value['release_year']}

      ●Genre:

      #{'TODO'}

      ●Condition: 

      #{value['record_grading']} #{record_description_jp}

      ●Grading Policy:

      M～NM～EX+～EX～EX-～VG+～VG～VG-~G+~G (10 grades) 

      M to EX → 非常に良い。

      EX-, VG+ → 傷、ノイズが多少あるが、おおむね良い。

      VG, VG- → 悪い。ノイズが多くのる場合がある。

      G+, G → 非常に悪い。ノイズが多い。

      ●配送方法:

      クリックポスト or ゆうパック

      すべての商品同梱可能です。複数枚ご購入いただく際は、ページをまとめますので、ご購入前にコメントにてご希望商品をご連絡ください。7インチ6枚までクリックポスト(185円)で発送可能です。7インチ7枚以上ご購入の際は、ゆうパックでの発送となります。

      ゆうパックの料金につきましては以下のリンクよりご確認ください。

      https://www.post.japanpost.jp/service/you_pack/charge/ichiran/13.html

      発送につきましては、月曜日から金曜日に行っております。大変申し訳ございませんが、土曜日・日曜日・祝日の発送は行っておりませんので、何卒ご理解のほどよろしくお願い申し上げます。

      その他ご不明な点やご要望などございましたら、お気軽にご連絡ください。

      ●試聴:

      A. Cool Aid
      https://drive.google.com/file/d/#{value['shopify用mp3_A']}/view?usp=sharing

      B. Detroit
      https://drive.google.com/file/d/#{value['shopify用mp3_B']}/view?usp=sharing

      ※PC以外の方は、画面上部中央にある下矢印のダウンロードボタンを押してから、試聴が開始されます。表示orダウンロードと出ますので、表示をクリックしてください。試聴は実際のレコードから録音しています。
    PRODUCT

    description
  end

end