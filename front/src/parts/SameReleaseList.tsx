import { Link } from 'react-router-dom';
import styled from 'styled-components';
import { formatGrading } from '../lib/format';
import { SameReleaseItem } from '../types/product';

// 同じ discogs_release_id の他の商品（docs/03-product-detail.md、99 B-6 でクライアント確定）。
// 商品登録・編集（04）でも同じものを置く。

const List = styled.ul`
  margin: 0;
  padding: 0;
  list-style: none;
  font-family: Menlo, Consolas, monospace;
  font-size: 14px;
`;
const Item = styled.li`
  padding: 4px 0;
`;
const ItemLink = styled(Link)`
  color: #3b5d8f;
  text-decoration: none;
  &:hover {
    text-decoration: underline;
  }
`;
const Empty = styled.p`
  margin: 0;
  font-size: 14px;
  color: #777;
`;

// "200000/EX-/780/7/1"。区切りの位置で項目を読む形式なので、空の値は "—" にせず空のままにする
const formatItem = (item: SameReleaseItem) =>
  [item.SKU, formatGrading(item.record_grading), item.price_jpy, item.price_usd, item.quantity]
    .map((value) => (value == null ? '' : String(value)))
    .join('/');

type Props = {
  items: SameReleaseItem[];
  // 遷移先の詳細でも「一覧に戻る」を効かせるため、一覧の URL を引き継ぐ
  from?: string;
};

export const SameReleaseList = ({ items, from }: Props) => {
  if (items.length === 0) {
    return <Empty>同じ discogs_release_id の商品はありません</Empty>;
  }

  return (
    <List>
      {items.map((item) => (
        <Item key={item.SKU}>
          <ItemLink to={`/products/${item.SKU}`} state={{ from }}>
            {formatItem(item)}
          </ItemLink>
        </Item>
      ))}
    </List>
  );
};
