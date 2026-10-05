class AddPlatformSettingsToGenres < ActiveRecord::Migration[7.0]
  # 出力先ごとの設定をジャンルマスタに持たせ、あわせて初期データを流し込む（docs/06-genre.md）。
  #
  # これまで各プラットフォーム向けの値は、ヘルパー内で「ジャンル id の数値範囲」から
  # 導いていた。
  #   mercari:       when 101..199 → "JAZZ ジャズ"
  #   yahoo:         when 102..199 → LP:ジャズ と LP:ジャズ:◯◯
  #   yahoo_auction: when 101..199 → カテゴリID "2084007027"
  #   ebay:          main が 'Jazz' か 'Soul / Funk / Blues' か
  # このため新しいジャンルを追加するときに id の範囲を外すと、エラーも出ないまま
  # 出力だけが間違う。新しい大分類（main）に至ってはコード修正が必要だった。
  #
  # 値をデータに移すことで、id は単なるキーになり自動採番できるようになる。
  #
  # yahoo_path は意味を広げる。従来は「カテゴリの末端名」だったが、
  # これからは「送信するカテゴリそのもの」を1行1件で持つ。
  #   従来 id=102: yahoo_path="ビッグバンド" → コードが LP:ジャズ と LP:ジャズ:ビッグバンド を生成
  #   今後 id=102: yahoo_path="ジャズ\nジャズ:ビッグバンド" → そのまま LP: を付けて出力
  # 4パターン（親のみ / 親＋親:子 / 親:子のみ / 子のみ）があり、
  # 列を分けても表現しきれないためこの形にした。
  #
  # yahoo_auction_category の 'by_artist_initial' は Rock / Pop 専用の特例。
  # ヤフオクの洋楽ロック/ポップはアーティスト名の頭文字でカテゴリが27通りに分かれるため、
  # この値のときだけコード側で頭文字から引く。
  #
  # SEED はスプレッドシート由来の48件に、上記の設定値を加えたもの。
  # 設定値は移行前のヘルパーの分岐から機械的に生成し、全商品で CSV 出力を
  # 突き合わせて差分を確認している。
  # **このマイグレーション単体で genres が完成する。**rake タスクの実行順に依存しない。
  SEED = [
    # [id, main, sub, yahoo_path, mercari_keywords, ebay_category, tags, yahoo_auction_category]
      [1, "Soul / Funk / Blues", "Soul", "ソウル", "SOUL ソウル", "Soul", "soul", "22284"],
      [2, "Soul / Funk / Blues", "Funk", "ファンク", "SOUL FUNK ソウル ファンク", "Soul", "funk", "22284"],
      [3, "Soul / Funk / Blues", "Blues", "ブルース", "BLUES ブルース", "Soul", "blues", "2084005265"],
      [4, "Soul / Funk / Blues", "Disco", "ディスコ", "SOUL DISCO ソウル ディスコ", "Soul", "disco", "22284"],
      [5, "Soul / Funk / Blues", "Gospel", "ゴスペル", "GOSPEL ゴスペル", "Soul", "gospel", "2084005265"],
      [6, "Soul / Funk / Blues", "Rhythm And Blues / Rock 'n' Roll", "リズム・アンド・ブルース/ロックンロール", "R&B R&R", "Soul", "rhythm-blues", "22284"],
      [10, "Soul / Funk / Blues", "60's Funk", "ファンク:60’sファンク", "SOUL FUNK ソウル ファンク", "Soul", "60s-funk", "22284"],
      [11, "Soul / Funk / Blues", "60's Soul", "ソウル:60’sソウル", "SOUL ソウル", "Soul", "60s-soul", "22284"],
      [12, "Soul / Funk / Blues", "70's Funk", "ファンク:70’sファンク", "SOUL FUNK ソウル ファンク", "Soul", "70s-funk", "22284"],
      [13, "Soul / Funk / Blues", "70's Soul", "ソウル:70’sソウル", "SOUL ソウル", "Soul", "70s-soul", "22284"],
      [14, "Soul / Funk / Blues", "80's / 90's Funk", "ファンク:80’s/90'sファンク", "SOUL FUNK ソウル ファンク", "Soul", "80s-funk", "22284"],
      [15, "Soul / Funk / Blues", "80's / 90's Soul", "ソウル:80’s/90'sソウル", "SOUL ソウル", "Soul", "80s-soul", "22284"],
      [16, "Soul / Funk / Blues", "2000's ~ Funk", "2000's~ファンク", "SOUL FUNK ソウル ファンク", "Soul", "2000s-funk", "22284"],
      [17, "Soul / Funk / Blues", "2000's ~ Soul", "2000's~ソウル", "SOUL ソウル", "Soul", "2000s-soul", "22284"],
      [18, "Soul / Funk / Blues", "2000's ~ Funk (New)", "2000's~ファンク", "SOUL FUNK ソウル ファンク", "Soul", "2000s-funk-new", "22284"],
      [19, "Soul / Funk / Blues", "2000's ~ Soul (New)", "2000's~ソウル", "SOUL ソウル", "Soul", "2000s-soul-new", "22284"],
      [101, "Jazz", "Dixieland Jazz / Swing Jazz", "ジャズ", "JAZZ ジャズ", "Jazz", "swing-jazz", "2084007027"],
      [102, "Jazz", "Big Band", "ジャズ\nジャズ:ビッグバンド", "JAZZ ジャズ", "Jazz", "big-band", "2084007027"],
      [103, "Jazz", "Modern Jazz", "ジャズ\nジャズ:モダン・ジャズ", "JAZZ ジャズ", "Jazz", "modern-jazz", "2084007027"],
      [104, "Jazz", "Bop", "ジャズ\nジャズ:バップ", "JAZZ ジャズ", "Jazz", "bop", "2084007027"],
      [105, "Jazz", "Hard Bop", "ジャズ\nジャズ:ハード・バップ", "JAZZ ジャズ", "Jazz", "hard-bop", "2084007027"],
      [106, "Jazz", "Post Bop", "ジャズ\nジャズ:ポスト・バップ", "JAZZ ジャズ", "Jazz", "post-bop", "2084007027"],
      [107, "Jazz", "Cool Jazz", "ジャズ\nジャズ:クール・ジャズ", "JAZZ ジャズ", "Jazz", "cool-jazz", "2084007027"],
      [108, "Jazz", "Latin Jazz", "ジャズ\nジャズ:ラテン・ジャズ", "JAZZ ジャズ", "Jazz", "latin-jazz", "2084007027"],
      [109, "Jazz", "Free Jazz / Spiritual Jazz", "ジャズ\nジャズ:フリー・ジャズ/スピリチュアル・ジャズ", "JAZZ ジャズ", "Jazz", "free-jazz-spiritual-jazz", "2084007027"],
      [110, "Jazz", "Jazz Funk / Soul Jazz", "ジャズ\nジャズ:ジャズ・ファンク/ソウル・ジャズ", "JAZZ ジャズ", "Jazz", "soul-jazz", "2084007027"],
      [111, "Jazz", "Jazz Rock / Fusion", "ジャズ\nジャズ:ジャズ・ロック/フュージョン", "JAZZ ジャズ", "Jazz", "jazz-rock-fusion", "2084007027"],
      [112, "Jazz", "Contemporary Jazz", "ジャズ\nジャズ:コンテンポラリー・ジャズ", "JAZZ ジャズ", "Jazz", "contemporary-jazz", "2084007027"],
      [113, "Jazz", "Vocal Jazz", "ジャズ\nジャズ:ヴォーカル・ジャズ", "JAZZ ジャズ", "Jazz", "vocal-jazz", "2084007027"],
      [114, "Jazz", "Japanese Jazz", "ジャズ\nジャズ:ジャパニーズ・ジャズ", "JAZZ ジャズ", "Jazz", "japanese-jazz", "2084007027"],
      [115, "Jazz", "Modal", "ジャズ\nジャズ:モーダル・ジャズ", "JAZZ ジャズ", "Jazz", "modal", "2084007027"],
      [116, "Jazz", "Bossa Nova", "ジャズ\nジャズ:ボサノヴァ", "JAZZ ジャズ", "Jazz", "bossa-nova", "2084007027"],
      [117, "Jazz", "Jazz Other", "ジャズ\nジャズ:ジャズその他", "JAZZ ジャズ", "Jazz", "jazz-other", "2084007027"],
      [201, "Reggae", "Ska", "スカ/レゲエ", "REGGAE レゲエ", nil, nil, "2084048577"],
      [202, "Reggae", "Rock Steady", "スカ/レゲエ", "REGGAE レゲエ", nil, nil, "2084048577"],
      [203, "Reggae", "Early Reggae", "スカ/レゲエ", "REGGAE レゲエ", nil, nil, "2084048577"],
      [204, "Reggae", "Roots Reggae (70's~80's)", "スカ/レゲエ", "REGGAE レゲエ", nil, nil, "2084048577"],
      [205, "Reggae", "Reggae", "スカ/レゲエ", "REGGAE レゲエ", nil, "reggae", "2084048577"],
      [206, "Reggae", "Dub (70's~80's)", "スカ/レゲエ", "REGGAE レゲエ", nil, nil, "2084048577"],
      [207, "Reggae", "UK Roots, Dub", "スカ/レゲエ", "REGGAE レゲエ", nil, nil, "2084048577"],
      [208, "Reggae", "Roots Reggae (90's~00's~)", "スカ/レゲエ", "REGGAE レゲエ", nil, nil, "2084048577"],
      [301, "World Music", "Latin", "ラテン", "LATIN ラテン", nil, "latin", "2084048572"],
      [399, "World Music", "Cumbia", "クンビア", "CUMBIA クンビア", nil, "cumbia", "2084048572"],
      [400, "World Music", "World Music", "ワールド・ミュージック", "WORLD MUSIC ワールド・ミュージック", nil, nil, "2084048572"],
      [2000, "Rock / Pop", "Rock / Pop", "ロック/ポップ", "ROCK POP ロック ポップ", nil, "rock-pop", "by_artist_initial"],
      [3000, "Folk / Country", "Folk / Country", "フォーク/カントリー", "FOLK COUNTRY", nil, "folk-country", "2084048578"],
      [4000, "Hip Hop / R&B", "Hip Hop / R&B", "ヒップホップ/アール・アンド・ビー", "HIP HOP R&B", nil, "hip-hop-r-b", "22288"],
      [5000, "House / Techno", "House / Techno", "ハウス/テクノ", "HOUSE TECHNO ハウス テクノ", nil, "house-techno", "2084044743"],
  ].freeze

  COLUMNS = %w[id main sub yahoo_path mercari_keywords ebay_category tags yahoo_auction_category].freeze

  def up
    add_column :genres, :mercari_keywords, :string
    add_column :genres, :ebay_category, :string
    add_column :genres, :yahoo_auction_category, :string
    change_column :genres, :yahoo_path, :text, null: false

    now = Time.current
    assignments = COLUMNS.drop(1).map { |c| "#{c} = VALUES(#{c})" }.join(', ')
    SEED.each do |values|
      execute ActiveRecord::Base.sanitize_sql_array([
        "INSERT INTO genres (#{COLUMNS.join(', ')}, created_at, updated_at) " \
        "VALUES (#{(['?'] * COLUMNS.size).join(', ')}, ?, ?) " \
        "ON DUPLICATE KEY UPDATE #{assignments}, updated_at = VALUES(updated_at)",
        *values, now, now
      ])
    end

    # id は業務上の意味を失ったので自動採番にする。
    # products.SKU と違い、id 未指定で外部から取り込まれる経路が無いため
    # 「未記入の行が毎回新規採番される」事故は起きない。
    execute 'ALTER TABLE genres MODIFY id int NOT NULL AUTO_INCREMENT'
  end

  def down
    execute 'ALTER TABLE genres MODIFY id int NOT NULL'
    change_column :genres, :yahoo_path, :string, null: false
    remove_column :genres, :yahoo_auction_category
    remove_column :genres, :ebay_category
    remove_column :genres, :mercari_keywords
  end
end
