module Api
  # 商品一覧・検索（docs/02-product-list.md）と商品詳細（docs/03-product-detail.md）。
  # 更新（update）は入力チェックのみで、まだ保存しない。
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
    # 商品詳細（docs/03-product-detail.md）。
    # genre は id の連結なので、名前を出すためのジャンルも一緒に返す。
    # GET /api/genres は商品件数の集計を伴うため、詳細のたびには呼ばせない。
    def show
      product = find_product
      return render_not_found if product.nil?

      render json: {
        product: product.as_json(only: Product::DETAIL_COLUMNS),
        genres: Genre.where(id: product.genre_ids).order(:id).as_json(only: %w[id main sub]),
        same_release: product.same_release_products.as_json(only: Product::SAME_RELEASE_COLUMNS),
      }
    end

    # PATCH /api/products/:sku
    # **入力チェックだけ行い、保存はしない。** CSV 出力のたびにスプレッドシートの値で products が
    # 上書きされるため、保存先（シートへの書き戻しか、DB を正本にするか）が決まるまでは書き込まない。
    # 決まったら、valid? の後で実際に保存する処理をここに足し、persisted を true にする。
    def update
      product = find_product
      return render_not_found if product.nil?

      product.assign_attributes(product_params)

      if product.valid?(:admin_form)
        render json: { product: product.as_json(only: Product::DETAIL_COLUMNS), persisted: false }
      else
        render json: { errors: product.errors.to_hash }, status: :unprocessable_entity
      end
    end

    # GET /api/products/filter_options
    # 検索フォームのプルダウンの選択肢を実データから返す
    def filter_options
      render json: ProductSearch.filter_options
    end

    private

    # "abc" を to_i すると 0 になり SKU=0 を引いてしまうので、数字以外は最初から見つからない扱い
    def find_product
      Product.find_by(SKU: params[:sku]) if params[:sku].match?(/\A\d+\z/)
    end

    def render_not_found
      render json: { errors: { SKU: ['が見つかりません'] } }, status: :not_found
    end

    def product_params
      params.require(:product).permit(*Product::EDITABLE_COLUMNS)
    end
  end
end
