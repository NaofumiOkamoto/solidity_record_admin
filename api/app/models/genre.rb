# ジャンルマスタ。CSV 出力時のジャンル変換と、商品のジャンル表示に使う。
#
# yahoo_path / mercari_keywords / ebay_category / tags は出力先ごとの設定で、
# 以前はヘルパー内で id の数値範囲から導いていた。詳細は
# AddPlatformSettingsToGenres マイグレーションのコメントを参照。
class Genre < ApplicationRecord
  # id は AUTO_INCREMENT。以前は業務側が意味を持たせて手入力していたが、
  # 出力先ごとの設定を列に持たせたことで単なるキーになった（docs/06-genre.md）。
  validates :main, :sub, :yahoo_path, :mercari_keywords, presence: true

  # 任意項目は未設定を nil に寄せる。画面から空欄で保存したときに "" が混ざると、
  # 未設定の判定が2通りになってしまう。
  before_save do
    self.tags = tags.presence
    self.ebay_category = ebay_category.presence
  end

  # CSV 出力のヘルパーが参照する形に変換する。
  # キーは文字列（ヘルパー側が genre_map[id.to_s] で引くため）。
  # :yahoo_path_genre という名前はヘルパー6ファイルが使っているので変えない。
  def self.csv_map
    order(:id).to_h do |genre|
      [
        genre.id.to_s,
        {
          main: genre.main,
          sub: genre.sub,
          yahoo_path_genre: genre.yahoo_path,
          tags: genre.tags,
          mercari_keywords: genre.mercari_keywords,
          ebay_category: genre.ebay_category,
          yahoo_auction_category: genre.yahoo_auction_category,
        },
      ]
    end
  end

  # ジャンル id ごとの利用商品数。
  # ジャンルの数だけ SQL を投げると全件スキャンが48回走るので、
  # 1回読み出して Ruby 側で数える。
  def self.products_counts
    counts = Hash.new(0)
    Product.where.not(genre: [nil, '']).pluck(:genre).each do |value|
      Product.parse_genre_ids(value).each { |id| counts[id] += 1 }
    end
    counts
  end

  # この id を使っている商品の件数。削除の可否判定に使う
  def products_count
    Product.with_genre(id).count
  end
end
