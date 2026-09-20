module Api
  # 商品一覧・検索（docs/02-product-list.md）。読み取り専用。
  class ProductsController < ApplicationController
    # GET /api/products
    def index
      search = ProductSearch.new(params)

      render json: {
        products: search.records.as_json(only: ProductSearch::LIST_COLUMNS),
        meta: search.meta,
      }
    end

    # GET /api/products/filter_options
    # 検索フォームのプルダウンの選択肢を実データから返す
    def filter_options
      render json: ProductSearch.filter_options
    end
  end
end
