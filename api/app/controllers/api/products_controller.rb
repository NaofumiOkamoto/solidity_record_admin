module Api
  # 商品一覧・検索（docs/02-product-list.md）と商品詳細（docs/03-product-detail.md）。読み取り専用。
  class ProductsController < ApplicationController
    # GET /api/products
    def index
      search = ProductSearch.new(params)

      render json: {
        products: search.records.as_json(only: ProductSearch::LIST_COLUMNS),
        meta: search.meta,
      }
    end

    # GET /api/products/:sku
    # 商品詳細（docs/03-product-detail.md）。読み取り専用。
    # genre は id の連結なので、名前を出すためのジャンルも一緒に返す。
    # GET /api/genres は商品件数の集計を伴うため、詳細のたびには呼ばせない。
    def show
      # "abc" を to_i すると 0 になり SKU=0 を引いてしまうので、数字以外は最初から 404
      product = Product.find_by(SKU: params[:sku]) if params[:sku].match?(/\A\d+\z/)
      if product.nil?
        render json: { errors: { SKU: ['が見つかりません'] } }, status: :not_found
        return
      end

      render json: {
        product: product.as_json(only: Product::DETAIL_COLUMNS),
        genres: Genre.where(id: product.genre_ids).order(:id).as_json(only: %w[id main sub]),
        same_release: product.same_release_products.as_json(only: Product::SAME_RELEASE_COLUMNS),
      }
    end

    # GET /api/products/filter_options
    # 検索フォームのプルダウンの選択肢を実データから返す
    def filter_options
      render json: ProductSearch.filter_options
    end
  end
end
