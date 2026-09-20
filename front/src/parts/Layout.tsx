import { ReactNode } from 'react';
import { Link } from 'react-router-dom';
import styled from 'styled-components';

const Header = styled.header`
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 14px 24px;
  border-bottom: solid 2px #ebebeb;
  background-color: #fff;
`;
const TitleLink = styled(Link)`
  font-size: 18px;
  font-weight: bold;
  color: #222;
  text-decoration: none;
`;
const BackLink = styled(Link)`
  font-size: 14px;
  color: #3b5d8f;
  text-decoration: none;
  &:hover {
    text-decoration: underline;
  }
`;
const Main = styled.main`
  padding: 24px;
`;

type Props = {
  // トップ以外ではヘッダー左に「← 戻る」を出す
  back?: { to: string; label: string };
  children: ReactNode;
};

export const Layout = ({ back, children }: Props) => (
  <>
    <Header>
      {back && <BackLink to={back.to}>← {back.label}</BackLink>}
      <TitleLink to="/">Solidity Records 管理画面</TitleLink>
    </Header>
    <Main>{children}</Main>
  </>
);
