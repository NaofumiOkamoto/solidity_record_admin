// 一覧に表示する項目（docs/02-product-list.md A-2 でクライアント確定）
export type Product = {
  SKU: number;
  artist: string | null;
  title: string | null;
  label: string | null;
  country: string | null;
  number: string | null;
  genre: string | null;
  format: string | null;
  item_condition: string | null;
  price_jpy: number | null;
  price_usd: number | null;
  // "2026-10-29" の形
  registration_date: string | null;
  sold_date: string | null;
  sold_site: string | null;
  quantity: number | null;
};

export type ProductListMeta = {
  total: number;
  page: number;
  per_page: number;
  total_pages: number;
};

export type ProductListResponse = {
  products: Product[];
  meta: ProductListMeta;
};

// 選択肢は API 側で自然順（数字は数値として、その後アルファベット順）に並んでいる。
// フロントで並べ替えないこと。
export type FilterOption = {
  value: string;
  // 出現件数。画面には表示しない。他の検索条件を反映しない数字のため、
  // 出すと「Used を選べば2万件出る」と誤解される（実際は AND で絞られる）。
  // 実データの分布を調べるときに使えるので返してはいる。
  count: number;
};

// 検索フォームのジャンル選択肢。他の項目と違い id で絞り込み、
// 画面には main / sub を出すため形が異なる
export type GenreOption = {
  id: number;
  main: string;
  sub: string;
};

// GET /api/products/filter_options の戻り値。プルダウンの選択肢を実データから作る
export type FilterOptions = {
  item_condition: FilterOption[];
  sales_status: FilterOption[];
  sold_site: FilterOption[];
  country: FilterOption[];
  format: FilterOption[];
  // 編集フォームのグレードの入力候補に、中間の値（VG_VG+ など）を足すために使う
  record_grading: FilterOption[];
  cover_grading: FilterOption[];
  genres: GenreOption[];
};

// ヤフオクのカテゴリに入る特別な値。
// 洋楽ロック/ポップはアーティスト名の頭文字でカテゴリが27通りに分かれるため、
// この値のときだけ API 側が頭文字から引く。画面ではこの文字列を直接見せない。
export const YAHOO_AUCTION_BY_ARTIST_INITIAL = 'by_artist_initial';

// ジャンルマスタ（docs/06-genre.md）。
// id は products.genre から "1_19" のように "_" で連結して参照されるキー。自動採番。
// yahoo_path 以降は出力先ごとの設定で、CSV 出力がそのまま使う。
export type Genre = {
  id: number;
  main: string;
  sub: string;
  // Yahoo に送るカテゴリ。1行1件、":" で階層（例: "ジャズ\nジャズ:ビッグバンド"）
  yahoo_path: string;
  // メルカリ・ヤフオクの商品名に付けるキーワード
  mercari_keywords: string;
  // eBay のカテゴリ。未設定なら空欄で出力される
  ebay_category: string | null;
  // ヤフオクのカテゴリID。'by_artist_initial' はアーティスト名の頭文字で
  // 27通りに分かれる Rock / Pop 専用の特例
  yahoo_auction_category: string | null;
  // Shopify のタグ
  tags: string | null;
  // この id を使っている商品の件数。0 件のときだけ削除できる
  products_count: number;
  // 最終更新。認証が無いため「誰が」は記録できないが、いつ変わったかは追える
  updated_at: string;
};

// 入力欄はすべて文字列で扱う。id は自動採番なのでフォームには含めない
export type GenreForm = {
  main: string;
  sub: string;
  yahoo_path: string;
  mercari_keywords: string;
  ebay_category: string;
  yahoo_auction_category: string;
  tags: string;
};

// GET /api/products/:sku の戻り値（docs/03-product-detail.md）。
// 未使用の11項目とタイムスタンプは API が返さない
export type ProductDetail = {
  SKU: number;
  discogs_release_id: number | null;
  artist: string | null;
  title: string | null;
  label: string | null;
  country: string | null;
  number: string | null;
  release_year: number | null;
  genre: string | null;
  format: string | null;
  item_condition: string | null;
  record_grading: string | null;
  cover_grading: string | null;
  record_description_jp: string | null;
  record_description_en: string | null;
  cover_description_jp: string | null;
  cover_description_en: string | null;
  mp3_A: string | null;
  mp3_B: string | null;
  weight: number | null;
  img_count: number | null;
  price_jpy: number | null;
  price_usd: number | null;
  cost_price: string | null;
  quantity: number | null;
  registration_date: string | null;
  sold_date: string | null;
  sold_site: string | null;
  sales_status: string | null;
  // eBay の商品説明にだけ出る項目。登録フォームには載せない（99 B-1）
  recoding_date: string | null;
  track_list: string | null;
  personnel: string | null;
  discogs_listing_id: number | null;
};

// 同じ discogs_release_id の他の商品（99 B-6）
export type SameReleaseItem = {
  SKU: number;
  record_grading: string | null;
  price_jpy: number | null;
  price_usd: number | null;
  quantity: number | null;
};

export type ProductDetailResponse = {
  product: ProductDetail;
  // product.genre に含まれる id のうち、マスタにあるもの
  genres: GenreOption[];
  same_release: SameReleaseItem[];
};
