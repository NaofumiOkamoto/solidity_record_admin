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
  def shopify_format(value, genre_map)
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
          shopify_tags(value), # 'Tags',
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
          value['quantity'], # 'Variant Inventory Qty',
          'deny', # 'Variant Inventory Policy',
          'manual', # 'Variant Fulfillment Service',
          value['price'], # 'Variant Price',
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
          '', # 'Handle',
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
    handle = shopify_title(value).downcase
      .gsub(' ', '-')
      .gsub('(', '-')
      .gsub(')', '-')
      .gsub(',', '-')
      .gsub('&', '-')
      .gsub('/', '-')
      .gsub('.', '-')
      .gsub('\'', '')
      .squeeze('\-')

    handle.chop! if handle[-1] == '-'
    handle
  end

  def shopify_title(value)
    title = "#{value['artist']} - #{value['title']}" 
    if value['format'].start_with?('7 inch')
      title += ' (7 inch Record / Used)'
    end
    if value['format'].start_with?('LP')
      title += ' (LP Record / Used)'
    end
    title
  end

  def shopify_img_src(value, i)
    "https://cdn.shopify.com/s/files/1/0415/0791/3886/products/#{value['SKU']}_#{format("%02d", i + 1)}.jpg?v=#{params[:imgParams]}"
  end

  def shopify_tags(value)
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
    when '2LP'
      tags << '2-lp'
    when '3LP'
      tags << '3-lp'
    when '7 inch'
      tags << '7-inch'
      tags << 'new-arrivals-45'
    when '10 inch'
      tags << '10-inch'
    when '12 inch'
      tags << '12-inch'
    when 'Gatefold LP'
      tags << 'gatefold-lp'
    when 'Laserdisc'
      tags << 'laserdisc'
    end

    value['genre'].split('_').each do |genre_id|
      case genre_id.to_i
      when 1
        tags << 'soul'
      when 2
        tags << 'funk'
      when 3
        tags << 'blues'
      when 4
        tags << 'disco'
      when 5
        tags << 'gospel'
      when 6
        tags << 'rhythm-blues'
      when 10
        tags << '60s-funk'
      when 11
        tags << '60s-soul'
      when 12
        tags << '70s-funk'
      when 13
        tags << '70s-soul'
      when 14
        tags << '80s-funk'
      when 15
        tags << '80s-soul'
      when 101
        tags << 'swing-jazz'
      when 102
        tags << 'big-band'
      when 103
        tags << 'modern-jazz'
      when 104
        tags << 'bop'
      when 105
        tags << 'hard-bop'
      when 106
        tags << 'post-bop'
      when 107
        tags << 'cool-jazz'
      when 108
        tags << 'latin-jazz'
      when 109
        if value['item_condition'] == 'New'
          tags << 'free-jazz-spiritual-jazz'
        else
          tags << 'free-jazz-spiritual-jazz-new'
        end
      when 110
        if value['item_condition'] == 'New'
          tags << 'jazz-funk-soul-jazz-new'
        else
          tags << 'soul-jazz'
        end
      when 111
        tags << 'jazz-rock-fusion'
      when 112
        if value['item_condition'] == 'New'
          tags << 'contemporary-jazz-new'
        else
          tags << 'contemporary-jazz'
        end
      when 113
        tags << 'vocal-jazz'
      when 114
        tags << 'japanese-jazz'
      when 115
        tags << 'modal'
      when 201..299
        tags << 'reggae'
      when 301..398
        tags << 'latin'
      when 399
        tags << 'cumbia'
      when 2000
        tags << 'rock-pop'
      when 3000
        tags << 'folk-country'
      when 4000
        tags << 'hip-hop-r-b'
      end
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
    genre = []
    value['genre'].split('_').each do |id|
      genre << genre_map[id.to_s][:sub] if genre_map[id.to_s].present?
    end

    description = <<~BODY
      <meta charset="utf-8">
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Artist: #{value['artist']}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Title: #{value['title']}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Label: #{value['label']}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Country: #{value['country']}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Number: #{value['number']}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Format: #{value['format']}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Release Year: #{value['release_year']}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Genre: #{genre.join(', ')}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Item Condition: #{value['item_condition']}</span></p>
      <p data-mce-fragment="1"><span data-mce-fragment="1">●Record Grading: #{value['record_grading']&.gsub('_', '~')} (#{value['record_description_en']})</span></p>
      <p data-mce-fragment="1">-Grading Policy-</p>
      <p data-mce-fragment="1">M～NM～EX+～EX～EX-～VG+～VG～VG-~G+~G (10 grades)</p>
      <p data-mce-fragment="1">M → Still sealed.</p>
      <p data-mce-fragment="1">NM → Nearly perfect. Great shape.</p>
      <p data-mce-fragment="1">EX+ → It might has very slight wear, stains or marks. But great shape. Close to NM.</p>
      <p data-mce-fragment="1">EX → Some very slight wear, stains or marks. But great shape.</p>
      <p data-mce-fragment="1">EX- → Some(or slight) wear, stains or marks. Record might has some noise. But good shape.</p>
      <p data-mce-fragment="1">VG+ → Some(or many) wear, stains or marks. Record might has some noise. But good shape.</p>
      <p data-mce-fragment="1">VG → Many wear, stains or marks. Record might has loud noise.</p>
      <p data-mce-fragment="1">VG- to G → Bad condition. Too many wear, stains or marks. Record has loud noise.</p>
      <p data-mce-fragment="1">*Basically, our grading is based on 'Goldmine US' or 'Record Collector UK'. But our grading is more classified. Also, We check the condition of all items before listing(except sealed item). Our grading is visual. But the sound may be better than visual. Therefore, if there is an audio clip on the item page, we recommend that you listen to a sample of the item before purchasing. If you have any questions about grading, please feel free to contact us.</p>
      <p data-mce-fragment="1">*Also, you can order by e-mail. Please contact to solidityrecords@gmail.com</p>
      <p data-mce-fragment="1">*The listen sample is recorded from the actual item.</p>
      <p data-mce-fragment="1">A. #{value['title'].split(' / ')[0]}</p>
      <p data-mce-fragment="1">B. #{value['title'].split(' / ')[1]}</p>
    BODY
  end

end