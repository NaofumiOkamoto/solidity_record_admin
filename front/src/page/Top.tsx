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

export const Top = () => (
  <Layout>
    <Grid>
      <DisabledMenu>
        商品一覧
        <Note>準備中</Note>
      </DisabledMenu>
      <MenuLink to="/csv">CSV 出力</MenuLink>
      {/* 商品登録（フェーズ1）とダッシュボード（フェーズ3）は未実装 */}
      <DisabledMenu>
        商品登録
        <Note>準備中</Note>
      </DisabledMenu>
      <DisabledMenu>
        ダッシュボード
        <Note>準備中</Note>
      </DisabledMenu>
    </Grid>
  </Layout>
);
