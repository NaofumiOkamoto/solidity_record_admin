module YahooAuctionHelper

  def yahoo_auction_header(max_img_count)
    img_array = []
    max_img_count.times do |i|
      img_array << "画像#{i + 1}"
    end
    [
      'カテゴリ',
      'タイトル',
      '説明',
      '開始価格',
      '即決価格',
      '個数',
      '開催期間',
      '終了時間',
      *img_array,
      '商品発送元の都道府県',
      '送料負担',
      '代金支払い',
      'Yahoo!かんたん決済',
      'かんたん取引',
      '商品代引',
      '商品の状態',
      '返品の可否',
      '入札者評価制限',
      '悪い評価の割合での制限',
      '入札者認証制限',
      '自動延長',
      '早期終了',
      '値下げ交渉',
      '自動再出品',
      '自動値下げ',
      '自動値下げ価格変更率',
      '送料固定',
      '荷物の大きさ',
      '荷物の重量',
      'ネコポス',
      'ネコ宅急便コンパクト',
      'ネコ宅急便',
      'ゆうパケット',
      'ゆうパック',
      '発送までの日数',
      '受け取り後決済サービス',
      '海外発送',
      '出品者情報開示前チェック',
    ]
  end

  def yahoo_auction_format(value, genre, max_img_count)
    is_lp = value['format']&.include?('LP')
    img_array = []
    max_img_count.times do |i|
      if value['img_count'].to_i > i
        if i == 0
          img_array << "#{value['SKU']}.jpg"
        else
          img_array << "#{value['SKU']}_#{i}.jpg"
        end
      else
        img_array << ''
      end
    end

    return [
      yahoo_auction_category(value), # カテゴリ
      product_name(value), # タイトル
      yahoo_auction_body(value, genre), # 説明
      value['price_jpy'], # 開始価格
      value['price_jpy'], # 即決価格
      value['quantity'], # 個数
      '7', # 開催期間
      '23', # 終了時間
      *img_array,
      '東京都', # 商品発送元の都道府県
      '落札者', # 送料負担
      '先払い', # 代金支払い
      'はい', # Yahoo!かんたん決済
      'はい', # かんたん取引
      'いいえ', # 商品代引
      yahoo_auction_condition(value), # 商品の状態
      '返品可', # 返品の可否
      'いいえ', # 入札者評価制限
      'いいえ', # 悪い評価の割合での制限
      'いいえ', # 入札者認証制限
      'いいえ', # 自動延長
      'はい', # 早期終了
      'いいえ', # 値下げ交渉
      '3', # 自動再出品
      'いいえ', # 自動値下げ
      '', # 自動値下げ価格変更率
      'はい', # 送料固定
      is_lp ? '〜80cm' : '〜60cm', # 荷物の大きさ
      '〜2kg', # 荷物の重量
      'いいえ', # ネコポス
      'いいえ', # ネコ宅急便コンパクト
      'いいえ', # ネコ宅急便
      is_lp ? 'いいえ' : 'はい', # ゆうパケット
      'はい', # ゆうパック
      '1日〜2日', # 発送までの日数
      'いいえ', # 受け取り後決済サービス
      'いいえ', # 海外発送
      'いいえ', # 出品者情報開示前チェック
    ]
  end

  private

  def yahoo_auction_category(value)
    case value['genre'].split('_')[0].to_i
    when 1, 2, 4, 6
      '22284'
    when 3, 5
      '2084005265'
    when 101..199
      '2084007027'
    when 201..299
      '2084048577'
    when 301..400
      '2084048572'
    when 2000
      case value['artist'].first
      when 'A'
        '2084042708'
      when 'B'
        '2084042756'
      when 'C'
        '2084042780'
      when 'D'
        '2084042800'
      when 'E'
        '2084042815'
      when 'F'
        '2084042822'
      when 'G'
        '2084042836'
      when 'H'
        '2084042847'
      when 'I'
        '2084042854'
      when 'J'
        '2084042879'
      when 'K'
        '2084042897'
      when 'L'
        '2084042905'
      when 'M'
        '2084042933'
      when 'N'
        '2084042948'
      when 'O'
        '2084042955'
      when 'P'
        '2084042983'
      when 'Q'
        '2084042987'
      when 'R'
        '2084043012'
      when 'S'
        '2084043051'
      when 'T'
        '2084043070'
      when 'U'
        '2084043075'
      when 'V'
        '2084043086'
      when 'W'
        '2084043098'
      when 'X'
        '2084043102'
      when 'Y'
        '2084043106'
      when 'Z'
        '2084043111'
      when '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
        '2084042685'
      end
    when 3000
      '2084048578'
    when 4000
      '22288'
    when 5000
      '2084044743'
    end
  end

  def yahoo_auction_body(value, genre_map)
    record_description_jp = value['record_description_jp'].present? ? "(#{value['record_description_jp']})": ''
    cover_description_jp = value['cover_description_jp'].present? ? "(#{value['cover_description_jp']})": ''
    is_lp = value['format']&.include?('LP')
    is_inch = value['format']&.include?('inch')
    
    # 試聴音源の注釈を条件に応じて設定
    listening_note = if value['item_condition'] == 'New'
                       if is_inch
                         '※リンクのある曲名をクリックすると試聴ができます。新品のため、サンプル音源となります。'
                       elsif is_lp
                         '※リンクのあるタイトルをクリックすると試聴ができます。新品のため、サンプル音源となります。LPレコードの試聴はA1です。'
                       else
                         ''
                       end
                     else
                       if is_inch
                         '※リンクのあるタイトルをクリックすると試聴ができます。試聴は実際のレコードから録音しています。'
                       elsif is_lp
                         '※リンクのあるタイトルをクリックすると試聴ができます。試聴は実際のレコードから録音しています。LPレコードの試聴はA1→B1です。'
                       else
                         ''
                       end
                     end

    cover_grading = <<~COVER

      ●Cover Grading: #{value['cover_grading']&.gsub('_', '~')} #{cover_description_jp}<br><br>
    COVER

    grading = <<~GRADING
      #{cover_grading if value['cover_grading'].present?}
      ●Record Grading: #{value['record_grading']&.gsub('_', '~')} #{record_description_jp}<br><br>
    GRADING

    genre = []
    value['genre'].split('_').each do |id|
      genre << genre_map[id.to_s][:sub] if genre_map[id.to_s].present?
    end

    caption = <<~CAPTION

    ●Artist: #{value['artist'].gsub('_', ', ')}<br><br>

    ●Title: <A href="#{value['mp3_A']}">#{value['title'].split(' / ')[0]}</A> #{'/' if value['mp3_B'].present?} <A href="#{value['mp3_B']}">#{value['title'].split(' / ')[1]}</A><br><br>

    #{listening_note}<br><br>

    ●Label: #{value['label']}<br><br>

    ●Country: #{value['country']}<br><br>

    ●Number: #{value['number']}<br><br>

    ●Format: #{value['format']}<br><br>

    ●Release Year: #{value['release_year'] || 'Unknown'}<br><br>

    ●Genre: #{genre.join(', ')}<br><br>

    ●Item Condition: #{value['item_condition']}<br><br>
    #{grading if value['item_condition'] == 'Used'}
    ●Grading Policy:<br><br>
    
    M~NM~EX+~EX~EX-~VG+~VG~VG-~G+~G (10 grades) <br><br>
    
    M → 新品同様、未開封。<br><br>

    NM, EX+, EX → 非常に良い。<br><br>
    
    EX-, VG+ → 傷、ノイズが多少あるが、おおむね良い。<br><br>
    
    VG, VG- → 悪い。ノイズが多くのる場合がある。<br><br>
    
    G+, G → 非常に悪い。ノイズが多い。<br><br>
    
    ※当店の商品はすべて洗浄、再生確認済みです(新品、未開封品を除く)。グレーディングについては、原則、傷やダメージなど見た目での評価となります。傷の量に比べ、ノイズが比較的少ない盤もございますので、商品ページに試聴音源がある商品につきましては、ご購入前に試聴をおすすめいたします。<br><br>
    
    ●配送方法:<br><br>
    
    #{'ゆうパケット or ゆうパック<br><br>' if !is_lp} #{'ゆうパック<br><br>' if is_lp}
    
    #{'すべての商品同梱可能です。7インチ6枚までゆうパケットで発送可能です。7インチ7枚以上ご購入の際は、ゆうパックでの発送となります。ゆうパックの料金は地域、サイズにより異なりますので、ご注文後のご案内となります。<br><br>' if !is_lp}#{'すべての商品同梱可能です。ゆうパックの料金は地域、サイズにより異なります。<br><br>' if is_lp}
    
    また、同梱をご希望の際は、落札後に「まとめて取引」 をご利用くださいますようお願いいたします。もし単品で住所確定後等、「まとめて取引」ができない際は、お支払い前にメッセージにて同梱希望のご連絡をお願いいたします。単品ごとに送料をお支払いした場合は、単品での取引となり同梱いたしかねますのでご注意ください。<br><br>
    
    なお、発送は平日のみ行っております。大変申し訳ございませんが、土曜日・日曜日・祝日の発送は行っておりませんので、何卒ご理解のほどよろしくお願い申し上げます。<br><br>
    
    その他ご不明な点やご要望などございましたら、お気軽にご連絡ください。
    CAPTION
  end

  def yahoo_auction_condition(value)
    grading = value['record_grading']
    return if grading.nil?
    case grading.split('_')[0]
    when 'M'
      '新品'
    when 'NM'
      '未使用に近い'
    when 'EX+', 'EX'
      '目立った傷や汚れなし'
    when 'EX-', 'VG+'
      'やや傷や汚れあり'
    when 'VG', 'VG-'
      '傷や汚れあり'
    when 'G+', 'G'
      '全体的に状態が悪い'
    end
  end


end