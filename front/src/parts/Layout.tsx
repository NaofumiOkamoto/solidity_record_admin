import { ReactNode, useEffect, useRef, useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import styled from 'styled-components';
import { Menu, MENUS } from '../lib/menus';

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
// ヘッダーのドロップダウン（「マスタ」など、group をまとめたもの）
const Dropdown = styled.div`
  position: relative;
`;
const DropdownButton = styled.button<{ $current: boolean }>`
  padding: 0;
  border: none;
  background: none;
  font-size: 14px;
  color: ${(p) => (p.$current ? '#222' : '#3b5d8f')};
  font-weight: ${(p) => (p.$current ? 'bold' : 'normal')};
  cursor: pointer;
  &:hover {
    text-decoration: underline;
  }
`;
const DropdownList = styled.div`
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  z-index: 10;
  min-width: 140px;
  padding: 6px 0;
  background-color: #fff;
  border: solid 1px #ddd;
  border-radius: 4px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);

  & > a,
  & > span {
    display: block;
    padding: 6px 14px;
    white-space: nowrap;
  }
  & > a:hover {
    background-color: #eef3fa;
    text-decoration: none;
  }
`;
const Main = styled.main`
  padding: 24px;
`;

// 1件ぶんのリンク。今いる画面はリンクにせず、未実装の画面は押せない状態で出す
const MenuItem = ({ menu, pathname }: { menu: Menu; pathname: string }) => {
  if (!menu.enabled) return <Disabled title={menu.note}>{menu.label}</Disabled>;
  if (menu.to === pathname) return <Current>{menu.label}</Current>;
  return <NavLink to={menu.to}>{menu.label}</NavLink>;
};

// group をまとめたドロップダウン。押すと開き、外側のクリック・Esc・画面の移動で閉じる
const MenuGroup = ({ label, menus, pathname }: { label: string; menus: Menu[]; pathname: string }) => {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => setOpen(false), [pathname]);

  useEffect(() => {
    if (!open) return;
    const close = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    const closeOnEsc = (e: KeyboardEvent) => e.key === 'Escape' && setOpen(false);
    document.addEventListener('mousedown', close);
    document.addEventListener('keydown', closeOnEsc);
    return () => {
      document.removeEventListener('mousedown', close);
      document.removeEventListener('keydown', closeOnEsc);
    };
  }, [open]);

  return (
    <Dropdown ref={ref}>
      <DropdownButton
        type="button"
        $current={menus.some((menu) => menu.to === pathname)}
        aria-expanded={open}
        onClick={() => setOpen(!open)}
      >
        {label} ▾
      </DropdownButton>
      {open && (
        <DropdownList>
          {menus.map((menu) => (
            <MenuItem key={menu.to} menu={menu} pathname={pathname} />
          ))}
        </DropdownList>
      )}
    </Dropdown>
  );
};

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
          {MENUS.map((menu, index) => {
            if (!menu.group) return <MenuItem key={menu.to} menu={menu} pathname={pathname} />;
            // group はその先頭の位置に1つだけ出す
            if (MENUS.findIndex((m) => m.group === menu.group) !== index) return null;
            return (
              <MenuGroup
                key={menu.group}
                label={menu.group}
                menus={MENUS.filter((m) => m.group === menu.group)}
                pathname={pathname}
              />
            );
          })}
        </Nav>
      </Header>
      <Main>{children}</Main>
    </>
  );
};
