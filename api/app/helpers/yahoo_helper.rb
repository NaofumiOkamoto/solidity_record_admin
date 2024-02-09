module YahooHelper

  def yahoo_header
    [
      'path',
      'name',
      'code',
      'price',
      'caption',
      'explanation',
      'ship-weight',
      'taxable',
      'template',
      'delivery',
      'astk-code',
      'condition',
      'product-category',
      'display',
      'keep-stock',
      'postage-set',
      'taxrate-type',
      'pick-and-delivery-transport-rule-type',
    ]
  end

  def yahoo_format(value, genre)
    [
      yahoo_path(value, genre),# path
      product_name(value),# name mercari_helperにあるメソッドを使用
      value['SKU'],# code
      value['price_jpy'],# price
      yahoo_caption(value, genre),# caption
      product_name(value),# explanation
      value['weight'],# ship-weight
      '1',# taxable
      'IT03',# template
      '0',# delivery
      '0',# astk-code
      yahoo_condition(value),# condition
      '5331',# product-category
      '1',# display
      '1',# keep-stock
      '1',# postage-set
      '0.1',# taxrate-type
      '0',# pick-and-delivery-transport-rule-type
    ]
  end

  private
  def yahoo_path(value, genre_map)
    yahoo_path = value['genre'].split('_').map do |genre_id|
      yahoo_genre_map(value['format'], genre_id, genre_map)
    end

    yahoo_path.flatten.uniq.join("\n")
  end

  def yahoo_genre_map(format, genre_id, genre_map)
    convert_format =  format.gsub(/ inch/, 'インチ')
    case genre_id.to_i
    when 101
      ["#{convert_format}:ジャズ"]
    when 102..199
      ["#{convert_format}:ジャズ", "#{convert_format}:ジャズ:#{genre_map[genre_id.to_s][:yahoo_path_genre]}"]
    when 10, 12, 14
      ["#{convert_format}:ファンク:#{genre_map[genre_id.to_s][:yahoo_path_genre]}"]
    when 11, 13, 15
      ["#{convert_format}:ソウル:#{genre_map[genre_id.to_s][:yahoo_path_genre]}"]
    else
      ["#{convert_format}:#{genre_map[genre_id.to_s][:yahoo_path_genre]}"]
    end
  end

  def yahoo_condition(value)
    grading = value['record_grading']
    return if grading.nil?
    case grading.split('_')[0]
    when 'M'
      3
    when 'NM'
      4
    when 'EX+', 'EX'
      5
    when 'EX-', 'VG+'
      6
    when 'VG', 'VG-'
      7
    when 'G', 'G+'
      8
    end
  end

  def yahoo_caption(value, genre_map)
    record_description_jp = value['record_description_jp'].present? ? "(#{value['record_description_jp']})": ''
    cover_description_jp = value['cover_description_jp'].present? ? "(#{value['cover_description_jp']})": ''

    cover_grading = <<~COVER

      ●Cover Grading: #{value['cover_grading']&.gsub('_', '~')} #{cover_description_jp}<br><br>
    COVER

    genre = []
    value['genre'].split('_').each do |id|
      genre << genre_map[id.to_s][:sub] if genre_map[id.to_s].present?
    end

    caption = <<~CAPTION

      ●Artist: #{value['artist']}<br><br>

      ●Title: <A href="#{value['mp3_A']}">#{value['title'].split(' / ')[0]}</A> / <A href="#{value['mp3_B']}">#{value['title'].split(' / ')[1]}</A><br><br>

      ※リンクのある曲名をクリックすると試聴ができます。試聴は実際のレコードから録音しています。<br><br>

      ●Label: #{value['label']}<br><br>

      ●Country: #{value['country']}<br><br>

      ●Number: #{value['number']}<br><br>

      ●Format: #{value['format']}<br><br>

      ●Release Year: #{value['release_year'] || 'Unknown'}<br><br>

      ●Genre: #{genre.join(', ')}<br><br>

      ●Item Condition: #{value['item_condition']}<br><br>
      #{cover_grading if value['cover_grading'].present?}
      ●Record Grading: #{value['record_grading']&.gsub('_', '~')} #{record_description_jp}<br><br>

      ●Grading Policy:<br><br>

      M~NM~EX+~EX~EX-~VG+~VG~VG-~G+~G (10 grades) <br><br>

      M → 新品同様、未開封。<br><br>

      NM, EX+, EX → 非常に良い。<br><br>

      EX-, VG+ → 傷、ノイズが多少あるが、おおむね良い。<br><br>

      VG, VG- → 悪い。ノイズが多くのる場合がある。<br><br>

      G+, G → 非常に悪い。ノイズが多い。<br><br>

      ※当店の商品はすべて洗浄、再生確認済みです(新品、未開封品を除く)。グレーディングについては、原則、傷やダメージなど見た目での評価となります。傷の量に比べ、ノイズが比較的少ない盤もございますので、商品ページに試聴音源がある商品につきましては、ご購入前に試聴をおすすめいたします。<br><br>

      ●配送方法:<br><br>

      クリックポスト or ゆうパック<br><br>

      すべての商品同梱可能です。7インチ6枚までクリックポスト(185円)で発送可能です。7インチ7枚以上ご購入の際は、ゆうパックでの発送となります。7インチ7枚以上ご購入でクリックポストをお選びいただいた場合、ご注文後にゆうパックの送料に変更となりますので、あらかじめご了承くださいませ。<br><br>

      ゆうパックの料金につきましては以下のリンクよりご確認ください。<br><br>

      <A href="https://www.post.japanpost.jp/service/you_pack/charge/ichiran/13.html">ゆうパック料金表</A><br><br>

      購入金額10,000円以上の場合は、送料無料で発送いたします。

      また、発送は平日のみ行っております。大変申し訳ございませんが、土曜日・日曜日・祝日の発送は行っておりませんので、何卒ご理解のほどよろしくお願い申し上げます。<br><br>

      その他ご不明な点やご要望などございましたら、お気軽にご連絡ください。
    CAPTION
  end

end