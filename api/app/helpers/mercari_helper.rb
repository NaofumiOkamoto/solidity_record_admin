module MercariHelper
  IMG_COUNT = 10

  def mercari_header
    img_array = []
    IMG_COUNT.times do |i|
      img_array << "商品画像名_#{i + 1}"
    end
    header = [
      '商品名',
      '商品説明',
      'SKU1_種類',
      'SKU1_在庫数',
      'SKU1_商品管理コード',
      'SKU1_JANコード',
      'SKU2_種類',
      'SKU2_在庫数',
      'SKU2_商品管理コード',
      'SKU2_JANコード',
      'SKU3_種類',
      'SKU3_在庫数',
      'SKU3_商品管理コード',
      'SKU3_JANコード',
      'SKU4_種類',
      'SKU4_在庫数',
      'SKU4_商品管理コード',
      'SKU4_JANコード',
      'SKU5_種類',
      'SKU5_在庫数',
      'SKU5_商品管理コード',
      'SKU5_JANコード',
      'SKU6_種類',
      'SKU6_在庫数',
      'SKU6_商品管理コード',
      'SKU6_JANコード',
      'SKU7_種類',
      'SKU7_在庫数',
      'SKU7_商品管理コード',
      'SKU7_JANコード',
      'SKU8_種類',
      'SKU8_在庫数',
      'SKU8_商品管理コード',
      'SKU8_JANコード',
      'SKU9_種類',
      'SKU9_在庫数',
      'SKU9_商品管理コード',
      'SKU9_JANコード',
      'SKU10_種類',
      'SKU10_在庫数',
      'SKU10_商品管理コード',
      'SKU10_JANコード',
      'ブランドID',
      '販売価格',
      'カテゴリID',
      '商品の状態',
      '配送方法',
      '発送元の地域',
      '発送までの日数',
      '商品ステータス',
    ]
    img_array + header
  end

  def mercari_format(value, genre_map, label_map)
    img_row = Array.new(IMG_COUNT)
    img_count = value['img_count']
    IMG_COUNT.to_i.times do |i|
      if i == 0
        img_row[i] = "#{value['SKU']}.jpg"
      elsif img_count.to_i > i
        img_row[i] = "#{value['SKU']}_#{i}.jpg"
      else
        img_row[i] = ''
      end
    end
    genre = []
    value['genre'].split('_').each do |id|
      genre << genre_map[id.to_s][:sub] if genre_map[id.to_s].present?
    end
    is_lp = ['2LP','3LP','Gatefold LP','LP','2 LP','3 LP'].include?(value['format'])
    row = [
      product_name(value), # 商品名
      product_description(value, genre), # 商品説明
      '',
      value['quantity'], # SKU1_在庫数
      value['SKU'], # SKU1_商品管理コード
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      value['price_jpy'] + (is_lp ? 850 : 185), # 販売価格
      'rQXZaxCTHYJwurBjB687QC', # カテゴリID
      mercari_condition(value), # 商品の状態
      is_lp ? '3' : '1', # 配送方法
      'jp13', # 発送元の地域
      '1', # 発送までの日数
      '2', # 商品ステータス
    ]
    img_row + row
  end

  def product_name(value)
    genre, _ =  value['genre'].split('_')
    format = ''
    case value['format']
    when '7 inch', '7inch'
      format = '7インチ 45'
    when '10 inch', '10inch'
      format = '10インチ'
    when '12 inch','12inch'
      format = '12インチ'
    else
      format = 'LP'
    end

    base = "#{value['artist'].gsub('_', ', ')} #{value['title']} #{value['label']} #{value['country']} #{value['number']} #{value['SKU']}"
    case genre.to_i
    when 1
      return "#{base} SOUL ソウル レコード #{format}"
    when 2
      return "#{base} SOUL FUNK ソウル ファンク レコード #{format}"
    when 3
      return "#{base} BLUES ブルース レコード #{format}"
    when 4
      return "#{base} SOUL DISCO ソウル ディスコ レコード #{format}"
    when 5
      return "#{base} GOSPEL ゴスペル レコード #{format}"
    when 6
      return "#{base} R&B R&R レコード #{format}"
    when 101..199
      return "#{base} JAZZ ジャズ レコード #{format}"
    when 201..299
      return "#{base} REGGAE レゲエ レコード #{format}"
    when 301..398
      return "#{base} LATIN ラテン レコード #{format}"
    when 399
      return "#{base} CUMBIA クンビア レコード #{format}"
    when 2000..2099 
      return "#{base} ROCK POP ロック ポップ レコード #{format}"
    when 3000..3099 
      return "#{base} FOLK COUNTRY レコード #{format}"
    when 4000..4099 
      return "#{base} HIP HOP R&B レコード #{format}"
    when 5000
      return "#{base} HOUSE TECHNO ハウス テクノ レコード#{format}"
    end
  end

  private

  def mercari_condition(value)
    if value['item_condition'] == 'New'
      return 1
    end
    grading = value['record_grading']
    return if grading.nil?
    case grading.split('_')[0]
    when 'M', 'NM', 'EX+', 'EX'
      3
    when 'EX-', 'VG+'
      4
    when 'VG', 'VG-'
      5
    when 'G', 'G+'
      6
    end
  end

  def product_description(value, genre)
    record_description_jp = value['record_description_jp'].present? ? "(#{value['record_description_jp']})": ''
    cover_description_jp = value['cover_description_jp'].present? ? "(#{value['cover_description_jp']})": ''
    is_lp = ['2LP','3LP','Gatefold LP','LP','2 LP','3 LP'].include?(value['format'])
    is_7inch = ['7inch', '7 inch'].include?(value['format'])
    
    # 試聴音源の注釈を条件に応じて設定
    listening_note = if value['item_condition'] == 'New'
                       if value['format']&.include?('inch')
                         '※新品のため、サンプル音源となります。'
                       elsif value['format']&.include?('LP')
                         '※新品のため、サンプル音源となります。LPレコードの試聴はA1です。'
                       else
                         ''
                       end
                     else
                       if value['format']&.include?('inch')
                         '※試聴は実際のレコードから録音しています。'
                       elsif value['format']&.include?('LP')
                         '※LPレコードの試聴はA1→B1です。'
                       else
                         ''
                       end
                     end

    cover_grading = <<~COVER

      ●Cover Grading: #{value['cover_grading']&.gsub('_', '~')} #{cover_description_jp}
    COVER

    grading = <<~GRADING
      #{cover_grading if value['cover_grading'].present?}
      ●Record Grading: #{value['record_grading']&.gsub('_', '~')} #{record_description_jp}
    GRADING

    mp3_B = <<~B

      #{'B. ' if !is_lp}#{value['title'].split(' / ')[1]}
      #{value['mp3_B']}
    B

    inch_7 = <<~NONLP
      クリックポスト or ゆうパック

      すべての商品同梱可能です。複数枚ご購入の際は、ページをおまとめしますので、ご購入前に商品ページ内の「質問する」より同梱希望商品のご連絡をお願いいたします。2枚目より185円値引きさせていただきます。

      単品ごとにお支払いした場合は、単品での取引となり同梱いたしかねますのでご注意ください。

      複数枚ご購入の場合、7インチ6枚までクリックポスト(185円)で発送可能です。7インチ7枚以上ご購入の際は、ゆうパックでの発送となります。

      ゆうパックの料金につきましては以下のリンクよりご確認ください。

      https://www.post.japanpost.jp/service/you_pack/charge/ichiran/13.html

      購入金額10,000円以上で、送料無料となります。(各商品金額には送料185円が含まれております。そのため、『購入金額10,000円以上で送料無料』が適用される金額は、各商品金額から送料185円を引いた金額の合計となります。)
    NONLP

    non_inch_7 = <<~LP
      らくらくメルカリ便

      すべての商品同梱可能です。複数枚ご購入の際は、ページをおまとめしますので、ご購入前に商品ページ内の「質問する」より同梱希望商品のご連絡をお願いいたします。2枚目より7インチは185円、LPは850円値引きさせていただきます。

      単品ごとにお支払いした場合は、単品での取引となり同梱いたしかねますのでご注意ください。

      購入金額10,000円以上で、送料無料となります。(各商品金額には7インチは送料185円、LPは送料850円が含まれております。そのため、『購入金額10,000円以上で送料無料』が適用される金額は、各商品金額から各送料を引いた金額の合計となります。)
    LP

    description = <<~PRODUCT
      ●Artist: #{value['artist'].gsub('_', ', ')}

      ●Title: #{value['title']}

      ●Label: #{value['label']}

      ●Country: #{value['country']}

      ●Number: #{value['number']}

      ●Format: #{value['format']}

      ●Release Year: #{value['release_year'] || 'Unknown'}

      ●Genre: #{genre.join(', ')}

      ●Item Condition: #{value['item_condition']}
      #{grading if value['item_condition'] == 'Used'}
      ●Grading Policy:

      M~NM~EX+~EX~EX-~VG+~VG~VG-~G+~G (10 grades) 

      M → 新品同様、未開封。

      NM, EX+, EX → 非常に良い。

      EX-, VG+ → 傷、ノイズが多少あるが、おおむね良い。

      VG, VG- → 悪い。ノイズが多くのる場合がある。

      G+, G → 非常に悪い。ノイズが多い。

      ※当店の商品はすべて洗浄、再生確認済みです(新品、未開封品を除く)。グレーディングについては、原則、傷やダメージなど見た目での評価となります。傷の量に比べ、ノイズが比較的少ない盤もございますので、商品ページに試聴音源がある商品につきましては、ご購入前に試聴をおすすめいたします。

      ●配送方法:

      #{non_inch_7 if !is_7inch}#{inch_7 if is_7inch}
      発送につきましては、平日のみ行っております。大変申し訳ございませんが、土曜日・日曜日・祝日の発送は行っておりませんので、何卒ご理解のほどよろしくお願い申し上げます。

      その他ご不明な点やご要望などございましたら、お気軽にご連絡ください。

      ●試聴:

      #{'A. ' if !is_lp}#{value['title'].split(' / ')[0]}
      #{value['mp3_A']}
      #{mp3_B if value['mp3_B'].present?}
      #{listening_note}
    PRODUCT

    description
  end

end