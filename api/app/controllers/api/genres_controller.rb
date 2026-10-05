module Api
  # ジャンルマスタの管理（docs/06-genre.md）。
  # CSV 出力のジャンル変換がこのデータを使うため、削除は参照チェックを通してから行う。
  class GenresController < ApplicationController
    before_action :set_genre, only: %i[update destroy]

    # GET /api/genres
    def index
      counts = Genre.products_counts

      render json: {
        genres: Genre.order(:id).map { |genre| serialize(genre, counts[genre.id]) },
      }
    end

    # POST /api/genres
    def create
      genre = Genre.new(genre_params)

      if genre.save
        render json: { genre: serialize(genre, 0) }, status: :created
      else
        render json: { errors: genre.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH /api/genres/:id
    def update
      if @genre.update(genre_params)
        render json: { genre: serialize(@genre, @genre.products_count) }
      else
        render json: { errors: @genre.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/genres/:id
    def destroy
      count = @genre.products_count

      # 参照されている id を消すと、CSV 出力時に genre_map から引けず
      # 該当商品のジャンルが黙って欠落する
      if count.positive?
        return render json: {
          errors: ["このジャンルは商品#{count}件で使われているため削除できません"],
        }, status: :unprocessable_entity
      end

      @genre.destroy
      head :no_content
    end

    private

    def set_genre
      @genre = Genre.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: ['ジャンルが見つかりません'] }, status: :not_found
    end

    # id は AUTO_INCREMENT なので受け取らない
    def genre_params
      params.require(:genre).permit(:main, :sub, :yahoo_path, :mercari_keywords, :ebay_category,
                                   :yahoo_auction_category, :tags)
    end

    def serialize(genre, products_count)
      genre.as_json(only: %i[id main sub yahoo_path mercari_keywords ebay_category
                             yahoo_auction_category tags updated_at])
           .merge('products_count' => products_count.to_i)
    end
  end
end
