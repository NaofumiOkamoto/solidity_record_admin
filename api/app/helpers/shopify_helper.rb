module ShopifyHelper
  def shopify_header
    [
      'Handle',
      'Title',
      'Body (HTML)',
      'Vendor',
      'Product Category',
      'Type',
      'Tags',
      'Published',
      'Option1 Name',
      'Option1 Value',
      'Option2 Name',
      'Option2 Value',
      'Option3 Name',
      'Option3 Value',
      'Variant SKU',
      'Variant Grams',
      'Variant Inventory Tracker',
      'Variant Inventory Qty',
      'Variant Inventory Policy',
      'Variant Fulfillment Service',
      'Variant Price',
      'Variant Compare At Price',
      'Variant Requires Shipping',
      'Variant Taxable	',
      'Variant Barcode',
      'Image Src',
      'Image Position',
      'Image Alt Text',
      'Gift Card',
      'SEO Title',
      'SEO Description',
      'Google Shopping / Google Product Category',
      'Google Shopping / Gender',
      'Google Shopping / Age Group',
      'Google Shopping / MPN	',
      'Google Shopping / AdWords Grouping',
      'Google Shopping / AdWords Labels',
      'Google Shopping / Condition',
      'Google Shopping / Custom Product',
      'Google Shopping / Custom Label 0',
      'Google Shopping / Custom Label 1',
      'Google Shopping / Custom Label 2',
      'Google Shopping / Custom Label 3',
      'Google Shopping / Custom Label 4',
      'Variant Image',
      'Variant Weight Unit',
      'Variant Tax Code',
      'Cost per item',
      'Price / Eurozone',
      'Compare At Price / Eurozone	',
      'Price / International',
      'Compare At Price / International',
      'Price / United Kingdom',
      'Compare At Price / United Kingdom',
      'Price / United States',
      'Compare At Price / United States',
      'Status',
    ]
  end
  def shopify_format(value, genre_map, quantity: nil)
    rows = []
    value['img_count']&.times do |i|
      if i == 0
        rows << [
          shopify_handle(value), # 'Handle',
          shopify_title(value), # 'Title',
          shopify_body(value, genre_map), # 'Body (HTML)',
          'Solidity Records', # 'Vendor',
          '', # 'Product Category',
          value['format'], # 'Type',
          shopify_tags(value, genre_map), # 'Tags',
          'true', # 'Published',
          'Title', # 'Option1 Name',
          'Default Title', # 'Option1 Value',
          '', # 'Option2 Name',
          '', # 'Option2 Value',
          '', # 'Option3 Name',
          '', # 'Option3 Value',
          value['SKU'], # 'Variant SKU',
          value['weight'], # 'Variant Grams',
          'shopify', # 'Variant Inventory Tracker',
          quantity.nil? ? value['quantity'] : quantity, # 'Variant Inventory Qty',
          'deny', # 'Variant Inventory Policy',
          'manual', # 'Variant Fulfillment Service',
          quantity.nil? ? value['price_jpy'] : quantity, # 'Variant Price',
          '', # 'Variant Compare At Price',
          'true', # 'Variant Requires Shipping',
          'true', # 'Variant Taxable	',
          '', # 'Variant Barcode',
          shopify_img_src(value, i), # 'Image Src',
          i + 1, # 'Image Position',
          '', # 'Image Alt Text',
          'false', # 'Gift Card',
          '', # 'SEO Title',
          '', # 'SEO Description',
          '', # 'Google Shopping / Google Product Category',
          '', # 'Google Shopping / Gender',
          '', # 'Google Shopping / Age Group',
          '', # 'Google Shopping / MPN	',
          '', # 'Google Shopping / AdWords Grouping',
          '', # 'Google Shopping / AdWords Labels',
          '', # 'Google Shopping / Condition',
          '', # 'Google Shopping / Custom Product',
          '', # 'Google Shopping / Custom Label 0',
          '', # 'Google Shopping / Custom Label 1',
          '', # 'Google Shopping / Custom Label 2',
          '', # 'Google Shopping / Custom Label 3',
          '', # 'Google Shopping / Custom Label 4',
          '', # 'Variant Image',
          'g', # 'Variant Weight Unit',
          '', # 'Variant Tax Code',
          '', # 'Cost per item',
          '', # 'Price / Eurozone',
          '', # 'Compare At Price / Eurozone	',
          '', # 'Price / International',
          '', # 'Compare At Price / International',
          '', # 'Price / United Kingdom',
          '', # 'Compare At Price / United Kingdom',
          '', # 'Price / United States',
          '', # 'Compare At Price / United States',
          'active', # 'Status',
        ]
      else
        rows << [
          shopify_handle(value), # 'Handle',
          '', # 'Title',
          '', # 'Body (HTML)',
          '', # 'Vendor',
          '', # 'Product Category',
          '', # 'Type',
          '', # 'Tags',
          '', # 'Published',
          '', # 'Option1 Name',
          '', # 'Option1 Value',
          '', # 'Option2 Name',
          '', # 'Option2 Value',
          '', # 'Option3 Name',
          '', # 'Option3 Value',
          '', # 'Variant SKU',
          '', # 'Variant Grams',
          '', # 'Variant Inventory Tracker',
          '', # 'Variant Inventory Qty',
          '', # 'Variant Inventory Policy',
          '', # 'Variant Fulfillment Service',
          '', # 'Variant Price',
          '', # 'Variant Compare At Price',
          '', # 'Variant Requires Shipping',
          '', # 'Variant Taxable	',
          '', # 'Variant Barcode',
          shopify_img_src(value, i), # 'Image Src',
          i + 1, # 'Image Position',
          '', # 'Image Alt Text',
          '', # 'Gift Card',
          '', # 'SEO Title',
          '', # 'SEO Description',
          '', # 'Google Shopping / Google Product Category',
          '', # 'Google Shopping / Gender',
          '', # 'Google Shopping / Age Group',
          '', # 'Google Shopping / MPN	',
          '', # 'Google Shopping / AdWords Grouping',
          '', # 'Google Shopping / AdWords Labels',
          '', # 'Google Shopping / Condition',
          '', # 'Google Shopping / Custom Product',
          '', # 'Google Shopping / Custom Label 0',
          '', # 'Google Shopping / Custom Label 1',
          '', # 'Google Shopping / Custom Label 2',
          '', # 'Google Shopping / Custom Label 3',
          '', # 'Google Shopping / Custom Label 4',
          '', # 'Variant Image',
          '', # 'Variant Weight Unit',
          '', # 'Variant Tax Code',
          '', # 'Cost per item',
          '', # 'Price / Eurozone',
          '', # 'Compare At Price / Eurozone	',
          '', # 'Price / International',
          '', # 'Compare At Price / International',
          '', # 'Price / United Kingdom',
          '', # 'Compare At Price / United Kingdom',
          '', # 'Price / United States',
          '', # 'Compare At Price / United States',
          '', # 'Status',
        ]
      end
    end
    rows
  end

  def shopify_handle(value)
    return value['SKU'] if 203823 <= value['SKU'].to_i
    return value['SKU'] if 3278 <= value['SKU'].to_i && value['SKU'].to_i <= 99999

    handle = shopify_title(value).downcase
      .gsub(' ', '-')
      .gsub('(', '-')
      .gsub(')', '-')
      .gsub(',', '-')
      .gsub('&', '-')
      .gsub('/', '-')
      .gsub('.', '-')
      .gsub('\'', '')
      .gsub('\’', '')
      .squeeze('\-')

    if value['SKU'].to_i <= 201679
      handle = handle.gsub('7-inch', '7inch-vinyl')
    end

    handle.chop! if handle[-1] == '-'

    # # ishii_memoに「x枚目」があるときは「-x」をケツにつける
    # match = value['ishii_memo']&.match(/(\d+)枚目/)
    # handle << "-#{match[1]}" if match.present?

    # handle
  end

  def shopify_title(value)
    title = "#{value['artist'].gsub('_', ', ')} - #{value['title']}" 
    if value['format'].start_with?('7 inch')
      title += ' (7 inch Record / Used)'
    end
    if ['2LP','3LP','Gatefold LP','LP','2 LP','3 LP'].include?(value['format'])
      title += ' (LP Record / Used)'
    end
    title
  end

  def shopify_img_src(value, i)
    img_name = if i == 0
                 value['SKU']
               else
                 "#{value['SKU']}_#{i}"
               end

    if (value['SKU'].to_i <= 202296 && 99999 <= value['SKU'].to_i) || value['SKU'].to_i <= 3278
      img_name = "#{value['SKU']}_#{format("%02d", i + 1)}"
    end

    "https://cdn.shopify.com/s/files/1/0415/0791/3886/files/#{img_name}.jpg?v=#{params[:imgParams]}"
  end

  def shopify_tags(value, genre_map)
    tags = []

    case value['quantity']
    when 0
      tags << 'out-of-stock-collection'
    when 1..nil
      tags << 'in-stock-collection'
    end

    case value['format']
    when 'LP'
      tags << 'lp'
      tags << 'new-arrivals'
    when '2LP','2 LP','3LP','3 LP','Gatefold LP'
      tags << 'new-arrivals'
    when '7 inch'
      tags << '7-inch'
      tags << 'new-arrivals-45'
    when '10 inch'
      tags << '10-inch'
    when '12 inch'
      tags << '12-inch'
    when 'Laserdisc'
      tags << 'laserdisc'
    end

    value['genre'].split('_').each do |genre_id|
      tags << genre_map[genre_id.to_s][:tags]
      # case genre_id.to_i
      # when 1
      #   tags << 'soul'
      # when 2
      #   tags << 'funk'
      # when 3
      #   tags << 'blues'
      # when 4
      #   tags << 'disco'
      # when 5
      #   tags << 'gospel'
      # when 6
      #   tags << 'rhythm-blues'
      # when 10
      #   tags << '60s-funk'
      # when 11
      #   tags << '60s-soul'
      # when 12
      #   tags << '70s-funk'
      # when 13
      #   tags << '70s-soul'
      # when 14
      #   tags << '80s-funk'
      # when 15
      #   tags << '80s-soul'
      # when 101
      #   tags << 'swing-jazz'
      # when 102
      #   tags << 'big-band'
      # when 103
      #   tags << 'modern-jazz'
      # when 104
      #   tags << 'bop'
      # when 105
      #   tags << 'hard-bop'
      # when 106
      #   tags << 'post-bop'
      # when 107
      #   tags << 'cool-jazz'
      # when 108
      #   tags << 'latin-jazz'
      # when 109
      #   if value['item_condition'] == 'New'
      #     tags << 'free-jazz-spiritual-jazz'
      #   else
      #     tags << 'free-jazz-spiritual-jazz-new'
      #   end
      # when 110
      #   if value['item_condition'] == 'New'
      #     tags << 'jazz-funk-soul-jazz-new'
      #   else
      #     tags << 'soul-jazz'
      #   end
      # when 111
      #   tags << 'jazz-rock-fusion'
      # when 112
      #   if value['item_condition'] == 'New'
      #     tags << 'contemporary-jazz-new'
      #   else
      #     tags << 'contemporary-jazz'
      #   end
      # when 113
      #   tags << 'vocal-jazz'
      # when 114
      #   tags << 'japanese-jazz'
      # when 115
      #   tags << 'modal'
      # when 117
      #   tags << 'jazz-other'
      # when 201..299
      #   tags << 'reggae'
      # when 301..398
      #   tags << 'latin'
      # when 399
      #   tags << 'cumbia'
      # when 400
      #   tags << 'world-music'
      # when 2000
      #   tags << 'rock-pop'
      # when 3000
      #   tags << 'folk-country'
      # when 4000
      #   tags << 'hip-hop-r-b'
      # when 5000
      #   tags << 'house-techno'
      # end
    end

    case value['label']
    when 'Blue Note'
      tags << 'blue-note-records'
    when 'ECM'
      tags << 'ecm-records'
    when 'Impulse!'
      tags << 'impulse-records'
    when 'International Anthem'
      tags << 'international-anthem-recording-company'
    when 'Jazzman'
      tags << 'jazzman-records'
    when 'Prestige'
      tags << 'prestige-records'
    when 'Riverside'
      tags << 'riverside-records'
    when 'Three Blind Mice'
      tags << 'three-blind-mice'
    end

    case value['artist']
    when 'Bill Evans'
      tags << 'bill-evans'
    when 'John Coltrane'
      tags << 'john-coltrane'
    when 'Miles Davis'
      tags << 'miles-davis'
    end

    case value['item_condition']
    when 'New'
      tags << 'new-releases'
    end

    tags.join(', ')
  end

  def shopify_body(value, genre_map)
    record_description = value['record_description_jp'].present? ? "(#{value['record_description_jp']}#{value['record_description_en']})" : ''
    cover_description_en = value['cover_description_en'].present? ? "(#{value['cover_description_jp']}#{value['cover_description_en']})" : ''
    is_lp = ['2LP','3LP','Gatefold LP','LP','2 LP','3 LP'].include?(value['format'])

    cover_grading = <<~COVER
     <p data-mce-fragment=\"1\"><span data-mce-fragment=\"1\">●Cover Grading: #{value['cover_grading']&.gsub('_', '~')} #{cover_description_en}
    COVER

    genre = []
    value['genre'].split('_').each do |id|
      genre << genre_map[id.to_s][:sub] if genre_map[id.to_s].present?
    end

    mp3_A = "<audio controls controlslist=\"nodownload\" src=\"//drive.google.com/uc?id=#{value['mp3_A']}\"></audio>"
    mp3_B = "<audio controls controlslist=\"nodownload\" src=\"//drive.google.com/uc?id=#{value['mp3_B']}\"></audio>"

    # is_link = ['2LP','3LP','Gatefold LP','LP','2 LP', '3 LP'].exclude?(value['format'])
    is_link = value['mp3_A'].present?

    link_message = <<~LINK_MESSAGE
      <p data-mce-fragment="1"><span data-mce-fragment="1">※リンクのある曲名をクリックすると試聴ができます。試聴は実際のレコードから録音しています。#{'LPレコードの試聴はA1→B1です。' if is_lp}Please click the song title with the link. You can listen to the audio sample. The audio sample is recorded from the actual item.#{'The audio sample of the LP record is A1→B1.' if is_lp}</span></p>
    LINK_MESSAGE

    splited_title = value['title'].split(' / ')
    title_in_link = <<~TITLE
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Title: <A style="color: #2653D9; border: none" href="#{value['mp3_A']}" target="_blank">#{splited_title[0]}</A> #{'/' if value['mp3_B'].present?} <A style="color: #2653D9; border: none;" href="#{value['mp3_B']}" target="_blank">#{splited_title[1]}</A></span></p>
    TITLE

    title_not_in_link = <<~TITLE
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Title: #{splited_title[0]}#{splited_title[1] ? ' / ' + splited_title[1] : ''}</span></p>
    TITLE

    description = <<~BODY
      <meta charset="utf-8">
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Artist: #{value['artist'].gsub('_', ', ')}</span></p>
      #{is_link ? title_in_link : title_not_in_link}#{link_message if is_link}<p data-mce-fragment="1"><span data-mce-fragment="1">●Label: #{value['label']}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Country: #{value['country']}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Number: #{value['number']}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Format: #{value['format']}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Release Year: #{value['release_year'] || 'Unknown'}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Genre: #{genre.join(', ')}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Item Condition: #{value['item_condition']}</span></p>
      #{cover_grading if value['cover_grading'].present?}<p data-mce-fragment="1"><span data-mce-fragment="1">●Record Grading: #{value['record_grading']&.gsub('_', '~')} #{record_description}</span></p>
    BODY
  end

end
# #2653D9