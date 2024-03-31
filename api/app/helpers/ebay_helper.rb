module EbayHelper

  def ebay_header
    [
      'Action(SiteID=US|Country=Japan|Currency=USD|Version=1193|CC=UTF-8)',
      'CustomLabel',
      'Category',
      'Title',
      'ConditionID',
      'C:Artist',
      'C:Format',
      'C:Release Title',
      'C:Material',
      'C:Type',
      'C:Genre',
      'C:Record Label',
      'C:Record Size',
      'C:Speed',
      'C:Record Grading',
      'C:Release Year',
      'C:Sleeve Grading',
      'C:Country/Region of Manufacture',
      'Description',
      'Format',
      'Duration',
      'StartPrice',
      'Quantity',
      'Location',
      'ReturnProfileName',
      'PaymentProfileName',
      'ShippingProfileName',
      'PicURL',
    ]
  end

  def ebay_format(value, genre_map)
    [
      'Add', # Action(SiteID=US|Country=Japan|Currency=USD|Version=1193|CC=UTF-8)
      value['SKU'], # CustomLabel
      '176985', # Category
      ebay_title(value), # Title
      '3000', # ConditionID
      value['artist']&.gsub('_', ', '), # Artist
      'Record', # Format1
      value['title'], # Release Title
      'Vinyl', # Material
      value['format'], # Type
      ebay_genre(value, genre_map), # Genre
      value['label'], # Record Label
      ebay_record_size(value), # Record Size
      ebay_speed(value), # Speed
      record_grading(value), # Record Grading
      value['release_year'],
      record_grading(value), # Sleeve Grading
      value['country'], # Country/Region of Manufacture
      ebay_description(value, genre_map), # Description
      'FixedPrice', # Format2
      'GTC', # Duration
      "%.15g"%value['price_usd'], # StartPrice
      value['quantity'], # Quantity
      'Japan', # Location
      'Returns Accepted,Buyer,30 Days,Money Back,Int#0', # ReturnProfileName
      'eBay Payments', # PaymentProfileName
      ebay_shipping_Profile_name(value), # ShippingProfileName
      pic_url(value), # PicURL
    ]
  end

  # 確認事項
  # Titleの※相談箇所あり。帯の有無って何？
  # GenreがJazz以外のものはsubを表示？
  # Record SizeはLP 12inch 7inch 以外は空欄でOK?

  def ebay_title(value)
    obi = (value['cover_description_en'].include?('With insert and OB') || value['cover_description_en'].include?('With OBI')) ? ' OBI JAPAN VINYL LP JAZZ' : ' JAPAN VINYL LP JAZZ'
    "#{value['artist'].gsub('_', ', ')} #{value['title']} #{value['label']} #{value['number']}#{obi}"
  end

  private

  def record_grading(value)
    p '#################'
    p value['record_grading']
    case value['record_grading'].split('_')[0]
    when 'M'
      return 'Mint (M)'
    when 'NM', 'EX+'
      return 'Near Mint (NM or M-)'
    when 'EX'
      return 'Excellent (EX)'
    when 'EX-', 'VG+'
      return 'Very Good Plus (VG+)'
    when 'VG'
      return 'Very Good (VG)'
    when 'VG-', 'G+'
      return 'Good Plus (G+)'
    when 'G'
      return 'Good (G)'
    end
  end
  
  def ebay_genre(value, genre_map)
    genre = []
    value['genre'].split('_').each do |id|
      genre << genre_map[id.to_s][:main] if genre_map[id.to_s].present?
    end
    return 'Jazz' if genre.include?('Jazz')
    return 'Soul' if genre.include?('Soul / Funk / Blues')
  end

  def ebay_record_size(value)
    case value['format']
    when 'LP', '12 inch'
      return '12”'
    when '7 inch'
      return '7”'
    end
  end
  
  def ebay_speed(value)
    case value['format']
    when 'LP'
      return '33 RPM'
    when '7 inch'
      return '45 RPM'
    end
  end

  def ebay_shipping_Profile_name(value)
    return value['format']
  end

  def pic_url(value)
    urls = ''
    value['img_count']&.times do |i|
      if i == 0
        urls += "https://solidityrecords.jpn.org/image/#{value['SKU']}.jpg"
      else
        urls += "|https://solidityrecords.jpn.org/image/#{value['SKU']}_#{i}.jpg"
      end
    end
    return urls
  end

  def ebay_description(value, genre_map)

    recoding_date = <<~RECORDING_DATE

      ●Recording Date: #{value['recoding_date']}
    RECORDING_DATE
    
    track_list = <<~TRACK_LIST

      ●Track List: #{value['track_list']}
    TRACK_LIST

    personnel = <<~PERSONNEL

      ●Personnel: #{value['personnel']}
    PERSONNEL

    record_description_en = value['record_description_en'].present? ? "(#{value['record_description_en']})": ''
    cover_description_en = value['cover_description_en'].present? ? "(#{value['cover_description_en']})": ''
    cover_grading = <<~COVER

      #{value['cover_grading']&.gsub('_', '~')} #{cover_description_en}
    COVER

    genre = []
    value['genre'].split('_').each do |id|
      genre << genre_map[id.to_s][:sub] if genre_map[id.to_s].present?
    end

    description = <<~BODY
      <font rwr="1" size="4" style="font-family:Arial">
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">●Artist: #{value['artist']}</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p> 
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">●Title: #{value['title']}</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">●Label: #{value['label']}</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">●Country: #{value['country']}</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">●Number: #{value['number']}</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">●Format: #{value['format']}</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">●Release Year: #{value['release_year'] || 'Unknown'}</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">●Genre: #{genre.join(', ')}</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">●Item Condition: #{value['item_condition']}</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">●Cover Grading: #{cover_grading}</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">●Record Grading: #{value['record_grading']&.gsub('_', '~')} #{record_description_en}</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">-Grading Policy-</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">M~NM~EX+~EX~EX-~VG+~VG~VG-~G+~G (10 grades)</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">M → Still sealed.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">NM →&nbsp;Nearly perfect. Great shape.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">EX+ → It might has very slight wear, stains or marks. But great shape. Close to NM.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">EX → Some very slight wear, stains or marks. But great shape.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">EX- → Some(or slight) wear, stains or marks. Record might has some noises. But good shape.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">VG+ → Some(or many) wear, stains or marks. Record might has some noises. But good shape.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">VG → Many wear, stains or marks. Record might&nbsp;has loud noises.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">VG- to G → Bad condition. Too many wear, stains or marks. Record has loud noises.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">*Basically, our grading is based on 'Goldmine US' or 'Record Collector UK'. But our grading is more classified. If you have any questions about grading, please feel free to contact us.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">-Shipping Policy-</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">Airmail Shipping (Registered). It takes 7-15days anywhere in the world.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">・7"</font></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">uk, europe, australia, usa, middle east, russia, asia: $9</font></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">south america, africa: $11</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">・10",12",LP</font></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">uk, europe, australia, usa, middle east, russia, asia: $15</font></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">south america, africa: $17</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">*$2 per additional 7".</font></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">*$3 per additional 10",12",LP.</font></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">*Gatefold cover &amp; 2LP are $3 add.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">---------------------------------------------------------------------------------------------------------------------</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">Fedex or DHL (Registered). It takes 2-7days anywhere in the world.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">・7",10",12",LP</font></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">usa, asia, mexico, canada: $22</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">uk, europe, australia: $24</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">middle east, south america, africa: $37</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">*$2 per additional 7”.</font></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">*$3 per additional 10",12",LP.</font></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">*Gatefold cover &amp; 2LP are $3 add.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">*We can combine any number of items. If you buy multiple items, please wait your payment until you get the total invoice from us.</font></p>
      <p style="margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; min-height: 15px;"><font style="font-variant-ligatures: common-ligatures"></font><br></p>
      <p style="margin: 0.0px 0.0px 0.0px 0.0px"><font face="Hiragino Kaku Gothic ProN" color="#000000" style="font-variant-numeric: normal; font-variant-east-asian: normal; font-variant-alternates: normal; font-kerning: auto; font-optical-sizing: auto; font-feature-settings: normal; font-variation-settings: normal; font-variant-position: normal; font-stretch: normal; font-size: 10px; line-height: normal; font-family: &quot;Hiragino Kaku Gothic ProN&quot;; font-variant-ligatures: common-ligatures;">*Basically, we choice the shipping company. But if you have any preference about shipping company, please feel free to contact us. We will do the best to meet your preference.</font></p></font><font rwr="1" size="4" style="font-family:Arial"><p class="p2" style="font-family: &quot;Helvetica Neue&quot;; font-size: 18px; margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-stretch: normal; line-height: normal; -webkit-text-stroke-color: rgb(0, 0, 0);"><span class="s2" style="font-kerning: none;"><b></b></span></p></font>
    BODY

    description_2 = <<~BODY2
      ●Artist: #{value['artist']}

      ●Title: #{value['title']}

      ●Label: #{value['label']}

      ●Country: #{value['country']}

      ●Number: #{value['number']}

      ●Format: #{value['format']}

      ●Release Year: #{value['release_year'] || 'Unknown'}
      #{recoding_date if value['recoding_date'].present?}
      ●Genre: #{genre.join(', ')}
      #{track_list if value['track_list'].present?}#{personnel if value['personnel'].present?}
      ●Item Condition: #{value['item_condition']}
      #{cover_grading if value['cover_grading'].present?}
      ●Record Grading: #{value['record_grading']&.gsub('_', '~')} #{record_description_en}

      -Grading Policy-

      M~NM~EX+~EX~EX-~VG+~VG~VG-~G+~G (10 grades)

      M → Still sealed.

      NM → Nearly perfect. Great shape.

      EX+ → It might has very slight wear, stains or marks. But great shape. Close to NM.

      EX → Some very slight wear, stains or marks. But great shape.

      EX- → Some(or slight) wear, stains or marks. Record might has some noises. But good shape.

      VG+ → Some(or many) wear, stains or marks. Record might has some noises. But good shape.

      VG → Many wear, stains or marks. Record might has loud noises.

      VG- to G → Bad condition. Too many wear, stains or marks. Record has loud noises.

      *Basically, our grading is based on 'Goldmine US' or 'Record Collector UK'. But our grading is more classified. If you have any questions about grading, please feel free to contact us.

      -Shipping Policy-

      Airmail Shipping (Registered). It takes 7-15days anywhere in the world.

      ・7"
      uk, europe, australia, usa, middle east, russia, asia: $9
      south america, africa: $11

      ・10",12",LP
      uk, europe, australia, usa, middle east, russia, asia: $15
      south america, africa: $17

      *$2 per additional 7".
      *$3 per additional 10",12",LP.
      *Gatefold cover & 2LP are $3 add.

      ---------------------------------------------------------------------------------------------------------------------

      Fedex or DHL (Registered). It takes 2-7days anywhere in the world.

      ・7",10",12",LP
      usa, asia, mexico, canada: $22

      uk, europe, australia: $24

      middle east, south america, africa: $37

      *$2 per additional 7”.
      *$3 per additional 10",12",LP.
      *Gatefold cover & 2LP are $3 add.

      *We can combine any number of items. If you buy multiple items, please wait your payment until you get the total invoice from us.

      *Basically, we choice the shipping company. But if you have any preference about shipping company, please feel free to contact us. We will do the best to meet your preference.

    BODY2
    return description
  end

end