module PickingItemDeleteHelper

  # ピッキング用のリスト。棚から現物を探すため、artist と title を併記する。
  # 並びは delete_csv_filter の order(:SKU) により SKU 昇順。
  def picking_item_delete_header
    [
      'SKU',
      'sold_site',
      'artist',
      'title',
    ]
  end

  def picking_item_delete_format(sold_products, _, label_map)
    sold_products.map do |product|
      [
        product['SKU'],
        product['sold_site'],
        product['artist'],
        product['title'],
      ]
    end
  end

end
