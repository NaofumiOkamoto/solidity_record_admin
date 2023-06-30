module EbayHelper

  def ebay_header
    [
      'Action(SiteID=US|Country=Japan|Currency=USD|Version=1193|CC=UTF-8)',
      'CustomLabel',
      'Category',
      'Title',
      'ConditionID',
      'Artist',
      'Format1',
      'Release Title',
      'Material',
      'Type',
      'Genre',
      'Record Label',
      'Record Size',
      'Speed',
      'Record Grading',
      'Sleeve Grading',
      'Country/Region of Manufacture',
      'Description',
      'Format2',
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
      value['artist'], # Artist
      'Record', # Format1
      value['title'], # Release Title
      'Vinyl', # Material
      value['format'], # Type
      ebay_genre(value, genre_map), # Genre
      value['label'], # Record Label
      ebay_record_size(value), # Record Size
      ebay_speed(value), # Speed
      value['record_grading']&.gsub('_', '~'), # Record Grading
      value['cover_grading']&.gsub('_', '~'), # Sleeve Grading
      value['country'], # Country/Region of Manufacture
      ebay_description(value, genre_map), # Description
      'FixedPrice', # Format2
      'GTC', # Duration
      "%.15g"%value['price_jpy'], # StartPrice
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

  private

  def ebay_title(value)
    obi = (value['cover_description_en'].include?('with insert and OB') || value['cover_description_en'].include?('with OBI')) ? ' OBI JAPAN VINYL LP JAZZ' : ''
    "#{value['artist']} #{value['title']} #{value['label']} #{value['number']}#{obi}"
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
    case value['format']
    when 'LP'
      return 'Flat:Expedited Ship($22.00)/Flat:Economy Inte1'
    when 'Gatefold LP'
      return 'Flat:Expedited Ship($22.00)/Flat:Economy Inte#02'
    end
  end

  def pic_url(value)
    urls = value['pic_url'].split(', ').map do |id|
      "https://drive.google.com/uc?export=view&id=#{id}"
    end
    urls.join('|')
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

    genre = []
    value['genre'].split('_').each do |id|
      genre << genre_map[id.to_s][:sub] if genre_map[id.to_s].present?
    end

    description = <<~BODY
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

      ●Sleeve Condition: まだ

      ●Vinyl Condition: まだ

      -Grading Policy-

      M～NM～EX+～EX～EX-～VG+～VG～VG-~G+~G (10 grades)

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

    BODY
  end

end