import { Link } from 'react-router-dom';
import styled from 'styled-components';
import { Layout } from '../parts/Layout';

const Grid = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 260px));
  gap: 20px;
  margin-top: 20px;
`;
const MenuLink = styled(Link)`
  display: block;
  padding: 36px 20px;
  text-align: center;
  font-weight: bold;
  color: #222;
  text-decoration: none;
  background-color: #fff;
  border: solid 2px #b3b3b3;
  border-radius: 4px;
  &:hover {
    background-color: #ebebeb;
  }
`;
const DisabledMenu = styled.div`
  padding: 36px 20px;
  text-align: center;
  font-weight: bold;
  color: #999;
  background-color: #f5f5f5;
  border: solid 2px #e0e0e0;
  border-radius: 4px;
`;
const Note = styled.span`
  display: block;
  margin-top: 6px;
  font-size: 12px;
  font-weight: normal;
`;

// 並び順と活性／非活性はここだけで決まる。
// enabled: false は「未実装」または「実装済みだが公開前」の両方に使う。
const MENUS = [
  { label: '商品登録', to: '/products/new', enabled: false, note: '準備中' },
  // 実装済み。本番での確認が済むまで導線を出さない（URL 直打ちでは開ける）
  { label: '商品一覧', to: '/products', enabled: false, note: '準備中' },
  { label: 'CSV 出力', to: '/csv', enabled: true },
  { label: 'ダッシュボード', to: '/dashboard', enabled: false, note: '準備中' },
  // 実装済み。本番での確認が済むまで導線を出さない（URL 直打ちでは開ける）
  { label: 'ジャンル', to: '/genres', enabled: false, note: '準備中' },
];

export const Top = () => (
  <Layout>
    <Grid>
      {MENUS.map(({ label, to, enabled, note }) =>
        enabled ? (
          <MenuLink key={to} to={to}>
            {label}
          </MenuLink>
        ) : (
          <DisabledMenu key={to}>
            {label}
            <Note>{note}</Note>
          </DisabledMenu>
        ),
      )}
    </Grid>
  </Layout>
);
