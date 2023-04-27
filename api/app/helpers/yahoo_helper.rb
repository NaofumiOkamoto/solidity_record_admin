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
      value['price'],# price
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
  def yahoo_path(value, genre)
    data =
    yahoo_path = value['genre'].split('_').map do |genre_id|
      "#{value['format'].gsub(/ inch/, 'インチ')}:#{yahoo_genre_map(genre_id)}"
    end

    yahoo_path.join("\n")
  end

  def yahoo_genre_map(genre_id)
    case genre_id.to_i
    when 101
      'ディキシーランド・ジャズ/スウィング・ジャズ'
    when 102
      'ビッグバンド'
    when 103
      'モダン・ジャズ'
    when 104
      'バップ'
    when 105
      'ハード・バップ'
    when 106
      'ポスト・バップ'
    when 107
      'クール・ジャズ'
    when 108
      'ラテン・ジャズ'
    when 109
      'フリー・ジャズ/スピリチュアル・ジャズ'
    when 110
      'ジャズ・ファンク/ソウル・ジャズ'
    when 111
      'ジャズ・ロック/フュージョン'
    when 112
      'コンテンポラリー・ジャズ'
    when 113
      'ヴォーカル・ジャズ'
    when 114
      'ジャパニーズ・ジャズ'
    when 115
      'モーダル・ジャズ'
    when 116
      'ボサノヴァ'
    when 101..199
      'ジャズ'
    when 1
      'ソウル'
    when 11
      '60’sソウル'
    when 13
      '70’sソウル'
    when 15
      '80’sソウル'
    when 2
      'ファンク'
    when 10
      '60’sファンク'
    when 12
      '70’sファンク'
    when 14
      '80’sファンク'
    when 4
      'ディスコ'
    when 3
      'ブルース'
    when 5
      'ゴスペル'
    when 6
      'リズム・アンド・ブルース/ロックンロール'
    when 201..299
      'スカ/レゲエ'
    when 301
      'ラテン'
    when 399
      'クンビア'
    when 4000
      'ヒップホップ/アール・アンド・ビー)'
    when 2000
      'ロック/ポップ'
    when 3000
      'フォーク/カントリー'
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

    genre = []
    value['genre'].split('_').each do |id|
      genre << genre_map[id.to_s][:sub] if genre_map[id.to_s].present?
    end

    caption = <<~CAPTION

      ●Artist: #{value['artist']}<br><br>

      ●Title: <A href="https://drive.google.com/file/d/#{value['mp3_A']}/view?usp=sharing">#{value['title'].split(' / ')[0]}</A> / <A href="https://drive.google.com/file/d/#{value['mp3_B']}/view?usp=sharing">#{value['title'].split(' / ')[0]}</A><br><br>

      ※リンクのある曲名をクリックすると試聴ができます。PC以外の方は、画面上部中央にある下矢印のダウンロードボタンを押すと試聴が開始されます。環境によっては表示orダウンロードと出ますので、表示をクリックしてください。試聴は実際のレコードから録音しています。<br><br>

      ●Label: #{value['label']}<br><br>

      ●Country: #{value['country']}<br><br>

      ●Number: #{value['number']}<br><br>

      ●Format: #{value['format']}<br><br>

      ●Release Year: #{value['release_year']}<br><br>

      ●Genre: #{genre.join(', ')}<br><br>

      ●Item Condition: #{value['item_condition']}<br><br>

      ●Record Grading: #{value['record_grading']} #{record_description_jp}<br><br>

      ●Grading Policy:<br><br>

      M〜NM〜EX+〜EX〜EX-〜VG+〜VG〜VG-~G+~G (10 grades) <br><br>

      M to EX → 非常に良い。<br><br>

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