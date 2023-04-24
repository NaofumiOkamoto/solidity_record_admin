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
      'まだ',# path
      product_name(value),# name mercari_helperにあるメソッドを使用
      value['SKU'],# code
      value['price'],# price
      'まだ',# caption
      'まだ',# explanation
      value['weight'],# ship-weight
      '1',# taxable
      'IT03',# template
      '0',# delivery
      '0',# astk-code
      'まだ',# condition
      '5331',# product-category
      '1',# display
      '1',# keep-stock
      '1',# postage-set
      '0.1',# taxrate-type
      '0',# pick-and-delivery-transport-rule-type
    ]
  end

  private

end