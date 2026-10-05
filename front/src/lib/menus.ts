// 画面の一覧。トップのタイルとヘッダーのリンクの両方がここを参照する。
// 並び順と活性／非活性をここだけで決められるようにするため、定義を1か所に置く。
// enabled: false は未実装のもの。公開するときは true にする。
export type Menu = {
  label: string;
  to: string;
  enabled: boolean;
  note?: string;
};

export const MENUS: Menu[] = [
  { label: '商品登録', to: '/products/new', enabled: false, note: '準備中' },
  { label: '商品一覧', to: '/products', enabled: true },
  { label: 'CSV 出力', to: '/csv', enabled: true },
  { label: 'ダッシュボード', to: '/dashboard', enabled: false, note: '準備中' },
  { label: 'ジャンル', to: '/genres', enabled: true },
];
