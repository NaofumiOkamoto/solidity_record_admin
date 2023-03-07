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
  def shopify_format(value, _)
    rows = []
    value['img_count'].times do |i|
      if i == 0
        rows << [
          '', # 'Handle',
          shopify_title(value), # 'Title',
          'まだ', # 'Body (HTML)',
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
        tags << ''
      when 110
        tags << ''
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

end