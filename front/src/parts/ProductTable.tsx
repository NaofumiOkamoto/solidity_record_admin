import { MouseEvent } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import styled from 'styled-components';
import { GenreOption, Product } from '../types/product';

// 一覧に出している列はすべてソートできる（API 側の SORTABLE と対応）
type Column = {
  key: keyof Product;
  label: string;
  align?: 'left' | 'right';
  maxWidth?: string;
};

// 表示する列は docs/02-product-list.md A-2 でクライアント確定（2026-09-20 見直し、2026-11-05 にクライアント依頼で変更）
const COLUMNS: Column[] = [
  { key: 'SKU', label: 'SKU', align: 'right', maxWidth: '80px' },
  { key: 'artist', label: 'artist', maxWidth: '180px' },
  { key: 'title', label: 'title', maxWidth: '240px' },
  { key: 'label', label: 'label', maxWidth: '150px' },
  { key: 'country', label: 'country', maxWidth: '100px' },
  { key: 'number', label: 'number', maxWidth: '120px' },
  { key: 'genre', label: 'genre', maxWidth: '130px' },
  { key: 'format', label: 'format', maxWidth: '110px' },
  { key: 'item_condition', label: 'item_condition', maxWidth: '110px' },
  { key: 'price_jpy', label: 'price_jpy', align: 'right', maxWidth: '90px' },
  { key: 'price_usd', label: 'price_usd', align: 'right', maxWidth: '90px' },
  { key: 'registration_date', label: 'registration_date', maxWidth: '130px' },
  { key: 'sold_date', label: 'sold_date', maxWidth: '110px' },
  { key: 'sold_site', label: 'sold_site', maxWidth: '130px' },
  { key: 'quantity', label: '在庫', align: 'right', maxWidth: '60px' },
];

// 表の中だけをスクロールさせ、見出し行（Th の position: sticky）を常に見えるようにする。
// 横スクロールのために overflow を付けている以上、sticky はこの箱に対して効くため、
// 箱に高さの上限が無いと縦に伸びきってしまい見出しが固定されない（ジャンル一覧と同じ）。
// 上限は、件数・ページ送りの行と下のページ送りが同じ画面に収まる高さ
const Scroll = styled.div`
  overflow: auto;
  max-height: max(320px, calc(100vh - 140px));
  background-color: #fff;
  border: solid 1px #ddd;
  border-radius: 4px;
`;
const Table = styled.table`
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
  white-space: nowrap;
`;
const Th = styled.th<{ $align?: string }>`
  position: sticky;
  top: 0;
  /* 一覧の行より前面、検索フォームのカレンダーより背面に置く
     （カレンダー側は ProductSearchForm の .react-datepicker-popper で 20） */
  z-index: 1;
  background-color: #f5f5f5;
  border-bottom: solid 2px #e0e0e0;
  padding: 10px 12px;
  text-align: ${(p) => p.$align || 'left'};
  font-size: 12px;
  color: #555;
  cursor: pointer;
  user-select: none;
  white-space: nowrap;
  &:hover {
    background-color: #ebebeb;
  }
`;
const Td = styled.td<{ $align?: string; $maxWidth?: string }>`
  border-bottom: solid 1px #eee;
  padding: 8px 12px;
  text-align: ${(p) => p.$align || 'left'};
  max-width: ${(p) => p.$maxWidth || 'none'};
  overflow: hidden;
  text-overflow: ellipsis;
`;
const Row = styled.tr`
  cursor: pointer;
  &:nth-child(even) {
    background-color: #fafafa;
  }
  &:hover {
    background-color: #eef3fa;
  }
`;
const Empty = styled.p`
  margin: 0;
  padding: 40px;
  text-align: center;
  color: #777;
`;
// Ctrl / ⌘ + クリックで別タブに開けるよう、SKU だけは本物のリンクにする
const SkuLink = styled(Link)`
  color: #3b5d8f;
  text-decoration: none;
  &:hover {
    text-decoration: underline;
  }
`;
const Arrow = styled.span`
  margin-left: 4px;
  color: #3b5d8f;
`;

type Props = {
  products: Product[];
  // ジャンルマスタ。products.genre は "1_19" のような id の連結なので、
  // 名前を出すために引き当てる。取得できていないときは id をそのまま出す
  genres: GenreOption[];
  sort: string;
  order: 'asc' | 'desc';
  onSortChange: (column: string) => void;
};

export const ProductTable = ({ products, genres, sort, order, onSortChange }: Props) => {
  const genreNames = new Map(genres.map((genre) => [String(genre.id), genre.sub]));
  const navigate = useNavigate();
  const location = useLocation();
  // 詳細の「一覧に戻る」で検索条件・ページ・ソートごと戻れるよう、今の一覧の URL を渡す
  const fromList = { from: `${location.pathname}${location.search}` };

  // 行のどこを押しても詳細へ移る。ただしリンクや入力欄の上で押したときはそちらの操作を優先する
  // （SKU のリンクは自前で遷移する。在庫などを一覧で編集できるようにしたときに入力欄を置くため）
  const handleRowClick = (event: MouseEvent<HTMLTableRowElement>, sku: number) => {
    if ((event.target as HTMLElement).closest('a, button, input, select, textarea, label')) return;
    // 文字列を選択してコピーしようとしたときは移らない
    if (window.getSelection()?.toString()) return;
    navigate(`/products/${sku}`, { state: fromList });
  };

  // "1_19" → "Soul, 2000's ~ Soul (New)"。マスタに無い id は #1000 の形で見えるようにする
  const genreLabel = (value: string | null) => {
    if (!value) return '';
    return value
      .split('_')
      .map((id) => genreNames.get(id) || `#${id}`)
      .join(', ');
  };

  return (
  <Scroll>
    <Table>
      <thead>
        <tr>
          {COLUMNS.map((column) => (
            <Th key={column.key} $align={column.align} onClick={() => onSortChange(column.key)}>
              {column.label}
              {sort === column.key && <Arrow>{order === 'asc' ? '▲' : '▼'}</Arrow>}
            </Th>
          ))}
        </tr>
      </thead>
      <tbody>
        {products.map((product) => (
          <Row key={product.SKU} onClick={(event) => handleRowClick(event, product.SKU)}>
            {COLUMNS.map((column) => {
              const raw = product[column.key];
              const text =
                column.key === 'genre' ? genreLabel(product.genre) : raw == null ? '' : String(raw);
              return (
                // 省略表示した文字列はホバーで全文を出す
                <Td key={column.key} $align={column.align} $maxWidth={column.maxWidth} title={text}>
                  {column.key === 'SKU' ? (
                    <SkuLink to={`/products/${product.SKU}`} state={fromList}>
                      {text}
                    </SkuLink>
                  ) : (
                    text
                  )}
                </Td>
              );
            })}
          </Row>
        ))}
      </tbody>
    </Table>
      {products.length === 0 && <Empty>該当する商品がありません</Empty>}
    </Scroll>
  );
};
