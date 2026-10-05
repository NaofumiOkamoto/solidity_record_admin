import { ReactNode } from 'react';
import { Link, useLocation } from 'react-router-dom';
import styled from 'styled-components';
import { MENUS } from '../lib/menus';

const Header = styled.header`
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px 24px;
  padding: 12px 24px;
  border-bottom: solid 2px #ebebeb;
  background-color: #fff;
`;
// 行き先は常にトップなので、各画面から渡させず Layout 側で判断する
const BackLink = styled(Link)`
  font-size: 14px;
  color: #3b5d8f;
  text-decoration: none;
  white-space: nowrap;
  &:hover {
    text-decoration: underline;
  }
`;
const TitleLink = styled(Link)`
  font-size: 18px;
  font-weight: bold;
  color: #222;
  text-decoration: none;
`;
const Nav = styled.nav`
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 6px 18px;
  margin-left: auto;
  font-size: 14px;
`;
const NavLink = styled(Link)`
  color: #3b5d8f;
  text-decoration: none;
  &:hover {
    text-decoration: underline;
  }
`;
// 今いる画面はリンクにしない
const Current = styled.span`
  color: #222;
  font-weight: bold;
`;
// 未実装の画面。並びを把握できるよう、押せない状態で並べる
const Disabled = styled.span`
  color: #bbb;
  cursor: default;
`;
const Main = styled.main`
  padding: 24px;
`;

type Props = {
  children: ReactNode;
};

export const Layout = ({ children }: Props) => {
  const { pathname } = useLocation();

  return (
    <>
      <Header>
        {pathname !== '/' && <BackLink to="/">← 戻る</BackLink>}
        <TitleLink to="/">Solidity Records 管理画面</TitleLink>
        <Nav>
          {MENUS.map((menu) => {
            if (!menu.enabled) {
              return (
                <Disabled key={menu.to} title={menu.note}>
                  {menu.label}
                </Disabled>
              );
            }
            if (menu.to === pathname) {
              return <Current key={menu.to}>{menu.label}</Current>;
            }
            return (
              <NavLink key={menu.to} to={menu.to}>
                {menu.label}
              </NavLink>
            );
          })}
        </Nav>
      </Header>
      <Main>{children}</Main>
    </>
  );
};
