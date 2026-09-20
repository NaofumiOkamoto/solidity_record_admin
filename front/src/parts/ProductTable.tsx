import styled from 'styled-components';
import { Product } from '../types/product';

type Column = {
  key: keyof Product;
  label: string;
  sortable?: boolean;
  align?: 'left' | 'right';
  maxWidth?: string;
};

// 表示する列は docs/02-product-list.md A-2 でクライアント確定（2026-09-20 見直し）
const COLUMNS: Column[] = [
  { key: 'SKU', label: 'SKU', sortable: true, align: 'right', maxWidth: '80px' },
  { key: 'artist', label: 'artist', sortable: true, maxWidth: '180px' },
  { key: 'title', label: 'title', sortable: true, maxWidth: '240px' },
  { key: 'label', label: 'label', maxWidth: '150px' },
  { key: 'country', label: 'country', maxWidth: '100px' },
  { key: 'number', label: 'number', maxWidth: '120px' },
  { key: 'release_year', label: 'release_year', sortable: true, align: 'right', maxWidth: '90px' },
  { key: 'genre', label: 'genre', maxWidth: '130px' },
  { key: 'format', label: 'format', maxWidth: '110px' },
  { key: 'item_condition', label: 'item_condition', maxWidth: '110px' },
  { key: 'quantity', label: '在庫', align: 'right', maxWidth: '60px' },
];

const Scroll = styled.div`
  overflow-x: auto;
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
const Th = styled.th<{ $align?: string; $sortable?: boolean }>`
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
  cursor: ${(p) => (p.$sortable ? 'pointer' : 'default')};
  user-select: none;
  &:hover {
    background-color: ${(p) => (p.$sortable ? '#ebebeb' : '#f5f5f5')};
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
const Arrow = styled.span`
  margin-left: 4px;
  color: #3b5d8f;
`;

type Props = {
  products: Product[];
  sort: string;
  order: 'asc' | 'desc';
  onSortChange: (column: string) => void;
};

export const ProductTable = ({ products, sort, order, onSortChange }: Props) => (
  <Scroll>
    <Table>
      <thead>
        <tr>
          {COLUMNS.map((column) => (
            <Th
              key={column.key}
              $align={column.align}
              $sortable={column.sortable}
              onClick={() => column.sortable && onSortChange(column.key)}
            >
              {column.label}
              {sort === column.key && <Arrow>{order === 'asc' ? '▲' : '▼'}</Arrow>}
            </Th>
          ))}
        </tr>
      </thead>
      <tbody>
        {products.map((product) => (
          <Row key={product.SKU}>
            {COLUMNS.map((column) => {
              const raw = product[column.key];
              const text = raw == null ? '' : String(raw);
              return (
                // 省略表示した文字列はホバーで全文を出す
                <Td key={column.key} $align={column.align} $maxWidth={column.maxWidth} title={text}>
                  {text}
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
