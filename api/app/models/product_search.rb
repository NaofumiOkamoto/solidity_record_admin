# 商品一覧・検索（docs/02-product-list.md）の絞り込み・並び替え・ページングを組み立てる。
#
# 検索条件はすべてクエリパラメータで受け取り、空欄の条件は無視して AND で結合する。
# 列名はすべて下記の定数（許可リスト）から取るため、パラメータの値が列名や SQL として
# 解釈されることはない。
class ProductSearch
  # 部分一致。照合順序が utf8mb4_0900_ai_ci のため大文字小文字は区別されない
  LIKE_COLUMNS = %w[artist title label number genre].freeze

  # 完全一致。値の種類が限られていて画面ではプルダウンで選ぶ列。
  # country と format は当初部分一致にしていたが、候補から選んだ値より広くヒットしてしまう
  # （country=US が Australia に、format=LP が Gatefold LP / 2LP に当たる）ため
  # 2026-09-20 に完全一致へ変更した。
  EXACT_COLUMNS = %w[country format item_condition sales_status].freeze

  # 完全一致の整数列。値が数値でなければ「指定なし」として無視する
  INTEGER_COLUMNS = %w[SKU discogs_release_id].freeze

  # 範囲検索。パラメータ名は <列名>_from / <列名>_to。値は型に合わせてキャストする
  RANGE_COLUMNS = {
    'release_year' => :integer,
    'price_jpy' => :integer,
    'price_usd' => :float,
    'registration_date' => :date,
    'sold_date' => :date,
  }.freeze

  # ソート可能な列。ここに無い値が来たら DEFAULT_SORT にフォールバックする
  SORTABLE = %w[SKU artist title release_year price_jpy registration_date sold_date].freeze
  DEFAULT_SORT = 'SKU'.freeze

  # 一覧に返す列（A-2 でクライアント確定。2026-09-20 に見直し）
  LIST_COLUMNS = %w[
    SKU artist title label country number
    release_year genre format item_condition quantity
  ].freeze

  # プルダウンの選択肢を実データから作る列
  FILTER_OPTION_COLUMNS = %w[item_condition sales_status sold_site country format].freeze

  DEFAULT_PER_PAGE = 50
  MAX_PER_PAGE = 100

  # プルダウン・入力候補の選択肢を実データから組み立てる。
  # 想定値を決め打ちにすると表記ゆれ（yahoo_auction_2 など）を取りこぼすため、
  # DB の実データをそのまま選択肢にする。
  #
  # count は画面には出さない（他の検索条件を反映しない数字のため誤解を招く）。
  # 実データの分布を調べるときに使えるので返してはいる。
  def self.filter_options
    FILTER_OPTION_COLUMNS.to_h do |column|
      counts = Product.where.not(column => [nil, '']).group(column).count
      options = counts.sort_by { |value, _count| natural_sort_key(value) }
                      .map { |value, count| { value: value, count: count } }
      [column, options]
    end
  end

  # 数字を含む値を見た目どおりに並べるためのキー。
  # 単純な文字列比較だと 10inch < 2LP < 7 inch となってしまうため、
  # 数字の連なりは数値として比較する（2LP → 3LP → 7 inch → 10inch → 12inch）。
  # 数字始まりの値を英字始まりより前に置き、英字は大文字小文字を区別しない。
  def self.natural_sort_key(value)
    value.to_s.downcase.scan(/\d+|\D+/).map do |chunk|
      chunk.match?(/\A\d+\z/) ? [0, chunk.to_i, ''] : [1, 0, chunk]
    end
  end
  private_class_method :natural_sort_key

  def initialize(params)
    @params = params
  end

  def records
    ordered.offset((page - 1) * per_page).limit(per_page)
  end

  def total
    @total ||= filtered.count
  end

  def meta
    {
      total: total,
      page: page,
      per_page: per_page,
      total_pages: (total / per_page.to_f).ceil,
    }
  end

  def page
    value = @params[:page].to_i
    value < 1 ? 1 : value
  end

  def per_page
    value = @params[:per_page].to_i
    return DEFAULT_PER_PAGE if value < 1

    [value, MAX_PER_PAGE].min
  end

  def sort_column
    SORTABLE.include?(@params[:sort]) ? @params[:sort] : DEFAULT_SORT
  end

  def sort_order
    @params[:order] == 'asc' ? :asc : :desc
  end

  private

  def ordered
    scope = filtered.order(table[sort_column].public_send(sort_order))
    # ページングがずれないよう、同値のときの並びを SKU で固定する
    scope = scope.order(table['SKU'].desc) unless sort_column == 'SKU'
    scope.select(*LIST_COLUMNS)
  end

  def filtered
    @filtered ||= begin
      scope = exclude_empty_records(Product.all)
      scope = apply_like(scope)
      scope = apply_exact(scope)
      scope = apply_sold_site(scope)
      scope = apply_integers(scope)
      apply_ranges(scope)
    end
  end

  # SKU だけ採番されて中身が空の仮登録行（2026-09 時点で99件）は一覧に出さない。
  # 詳細は docs/02-product-list.md の「既存データについての注意」を参照。
  def exclude_empty_records(scope)
    scope.where("COALESCE(artist, '') <> '' OR COALESCE(title, '') <> ''")
  end

  def apply_like(scope)
    LIKE_COLUMNS.reduce(scope) do |result, column|
      value = @params[column]
      next result if value.blank?

      result.where(table[column].matches("%#{escape_like(value)}%"))
    end
  end

  def apply_exact(scope)
    EXACT_COLUMNS.reduce(scope) do |result, column|
      value = @params[column]
      next result if value.blank?

      result.where(column => value)
    end
  end

  # sold_site は前方一致。yahoo_auction_2 / yahoo_auction_3 のような連番付きの値が
  # 実在するため、完全一致だと取りこぼす（既存の delete_csv_filter と同じ扱い）。
  def apply_sold_site(scope)
    value = @params[:sold_site]
    return scope if value.blank?

    scope.where(table['sold_site'].matches("#{escape_like(value)}%"))
  end

  def apply_integers(scope)
    INTEGER_COLUMNS.reduce(scope) do |result, column|
      value = cast(@params[column], :integer)
      next result if value.nil?

      result.where(column => value)
    end
  end

  def apply_ranges(scope)
    RANGE_COLUMNS.reduce(scope) do |result, (column, type)|
      from = cast(@params["#{column}_from"], type)
      to = cast(@params["#{column}_to"], type)

      result = result.where(table[column].gteq(from)) if from
      result = result.where(table[column].lteq(to)) if to
      result
    end
  end

  def table
    Product.arel_table
  end

  def escape_like(value)
    ActiveRecord::Base.sanitize_sql_like(value.to_s.strip)
  end

  # 不正な値は「指定なし」として扱う（エラーにはしない）
  def cast(value, type)
    return nil if value.blank?

    case type
    when :integer then Integer(value, exception: false)
    when :float then Float(value, exception: false)
    when :date then Date.parse(value) rescue nil
    end
  end
end
