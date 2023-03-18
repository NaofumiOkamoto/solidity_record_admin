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
      'まだ', # Description
      'FixedPrice', # Format2
      'GTC', # Duration
      value['discogs_price'], # StartPrice
      value['quantity'], # Quantity
      'Japan', # Location
      'Returns Accepted,Buyer,30 Days,Money Back,Int#0', # ReturnProfileName
      'eBay Payments', # PaymentProfileName
      ebay_shipping_Profile_name(value), # ShippingProfileName
      'まだ', # PicURL
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

end