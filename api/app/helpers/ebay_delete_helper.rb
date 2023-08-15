module EbayDeleteHelper
  require 'json'
  require 'ebay/finding'
  require 'ebay/shopping'
  require 'net/http'
  require 'uri'
  include HTTParty

  def ebay_delete_header
    [
      'Action',
      'Item ID',
      'EndCode'
    ]
  end

  def ebay_delete_format(sold_products, _)

    ebay_solid_products = []
    begin
      # url = 'https://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findCompletedItems&SERVICE-VERSION=1.7.0&SECURITY-APPNAME=kazukiis-solidity-PRD-74252652f-b85a673b&RESPONSE-DATA-FORMAT=XML&REST-PAYLOAD&keywords=Garmin+nuvi+1300+Automotive+GPS+Receiver&categoryId=156955&itemFilter(0).name=Condition&itemFilter(0).value=3000&itemFilter(1).name=FreeShippingOnly&itemFilter(1).value=true&itemFilter(2).name=SoldItemsOnly&itemFilter(2).value=true&sortOrder=PricePlusShippingLowest&paginationInput.entriesPerPage=2'
      # url = "https://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByCategory&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=kazukiis-solidity-PRD-74252652f-b85a673b&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&categoryId=176985"

      sold_products.each do |product|
        keyword = ebay_title(product).gsub('&', ' ').gsub('#', ' ')
        url = "https://svcs.ebay.com/services/search/FindingService/v1?"\
          "OPERATION-NAME=findItemsIneBayStores"\
          "&SERVICE-VERSION=1.0.0"\
          "&SECURITY-APPNAME=kazukiis-solidity-PRD-74252652f-b85a673b"\
          "&RESPONSE-DATA-FORMAT=JSON"\
          "&REST-PAYLOAD"\
          "&storeName=Solidity+Records"\
          "&outputSelector=StoreInfo"\
          "&keywords=#{keyword}"

        uri = URI.parse(url)
        response = Net::HTTP.get(uri)
        json = JSON.parse(response, symbolize_names: true)

        result = json[:findItemsIneBayStoresResponse][0][:searchResult]
        if result[0][:item]
          p "count: #{result[0][:@count]}, keyword: #{keyword}"
          ebay_solid_products << ['End', result[0][:item][0][:itemId][0], 'NotAvailable']
        end
      end

    rescue => e
      p "ebay_deleteでエラーです"
      p e
    end

    ebay_solid_products
  end
end