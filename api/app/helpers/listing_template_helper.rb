module ListingTemplateHelper
  # price_jpy(スプシ AA 列)がこの金額以下の商品は簡易検品扱い
  LOW_PRICE_THRESHOLD = 580

  LOW_PRICE_NOTE_JP = '※本商品は簡易検品となります。ラベルにダメージ、書き込み、ステッカー等や、盤に再生には影響しない歪みがある場合がございます。再生に影響する激しいノイズや歪みがあるものではありませんが、細かいチェックはしておりませんので、あらかじめご了承くださいませ。'
  LOW_PRICE_NOTE_EN = '*Please note that this item undergoes a basic inspection. The label may have damage, markings, stickers, etc., or the disc may have minor warping that does not affect playback. While there is no severe noise or warping that would affect playback, please be aware that we do not perform detailed inspections.'

  def low_price?(value)
    value['price_jpy'].present? && value['price_jpy'].to_i <= LOW_PRICE_THRESHOLD
  end

  def mp3_present?(value)
    value['mp3_A'].present? || value['mp3_B'].present?
  end

  # 「A面 / B面」のタイトルを試聴リンク付きで返す。
  # mp3 が無い面はリンクにせず、区切りの「/」は mp3 の有無に関係なく入れる。
  def linked_title(value, anchor_attrs: '')
    urls = [value['mp3_A'], value['mp3_B']]
    value['title'].to_s.split(' / ').map.with_index { |text, i|
      urls[i].present? ? %(<A #{anchor_attrs}href="#{urls[i]}">#{text}</A>) : text
    }.join(' / ')
  end
end
