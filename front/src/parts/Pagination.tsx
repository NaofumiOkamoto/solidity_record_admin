import styled from 'styled-components';

const Nav = styled.nav`
  display: flex;
  align-items: center;
  gap: 4px;
`;
const PageButton = styled.button<{ $current?: boolean }>`
  min-width: 34px;
  padding: 6px 8px;
  background-color: ${(p) => (p.$current ? '#3b5d8f' : '#fff')};
  color: ${(p) => (p.$current ? '#fff' : '#333')};
  border: solid 1px ${(p) => (p.$current ? '#3b5d8f' : '#ccc')};
  border-radius: 2px;
  font-size: 13px;
  cursor: pointer;
  &:hover:not(:disabled) {
    background-color: ${(p) => (p.$current ? '#33517c' : '#ebebeb')};
  }
  &:disabled {
    opacity: 0.4;
    cursor: default;
  }
`;
const Ellipsis = styled.span`
  padding: 0 2px;
  color: #999;
`;

// 現在ページの前後2ページ＋先頭・末尾を出し、間は「…」で省略する
const buildPages = (page: number, totalPages: number) => {
  const pages = new Set<number>([1, totalPages]);
  for (let p = page - 2; p <= page + 2; p += 1) {
    if (p >= 1 && p <= totalPages) pages.add(p);
  }
  return Array.from(pages).sort((a, b) => a - b);
};

type Props = {
  page: number;
  totalPages: number;
  onChange: (page: number) => void;
};

export const Pagination = ({ page, totalPages, onChange }: Props) => {
  if (totalPages <= 1) return null;

  const pages = buildPages(page, totalPages);

  return (
    <Nav aria-label="ページ送り">
      <PageButton onClick={() => onChange(page - 1)} disabled={page <= 1}>
        ‹
      </PageButton>
      {pages.map((p, i) => (
        <span key={p}>
          {i > 0 && p - pages[i - 1] > 1 && <Ellipsis>…</Ellipsis>}
          <PageButton $current={p === page} onClick={() => onChange(p)}>
            {p}
          </PageButton>
        </span>
      ))}
      <PageButton onClick={() => onChange(page + 1)} disabled={page >= totalPages}>
        ›
      </PageButton>
    </Nav>
  );
};
