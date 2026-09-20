// 一覧に表示する項目（docs/02-product-list.md A-2 でクライアント確定）
export type Product = {
  SKU: number;
  artist: string | null;
  title: string | null;
  label: string | null;
  number: string | null;
  country: string | null;
  price_jpy: number | null;
  quantity: number | null;
  sales_status: string | null;
  registration_date: string | null;
  sold_date: string | null;
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
