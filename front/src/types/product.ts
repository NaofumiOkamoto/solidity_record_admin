// 一覧に表示する項目（docs/02-product-list.md A-2 でクライアント確定）
export type Product = {
  SKU: number;
  artist: string | null;
  title: string | null;
  label: string | null;
  country: string | null;
  number: string | null;
  release_year: number | null;
  genre: string | null;
  format: string | null;
  item_condition: string | null;
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

export type FilterOption = {
  value: string;
  // 出現件数。選択肢を多い順に並べるために API が返すが、画面には表示しない。
  // 他の検索条件を反映しない数字のため、出すと「Used を選べば2万件出る」と
  // 誤解される（実際は他条件との AND で絞られる）。
  count: number;
};

// GET /api/products/filter_options の戻り値。プルダウンの選択肢を実データから作る
export type FilterOptions = {
  item_condition: FilterOption[];
  sales_status: FilterOption[];
  sold_site: FilterOption[];
  country: FilterOption[];
  format: FilterOption[];
};
