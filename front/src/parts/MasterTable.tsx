import styled from 'styled-components';
import { Input } from './ui';

// マスタ管理画面（ジャンル・説明文の定型文）の表の部品。
// 1行ずつ「編集」→ 行内で入力 →「保存」する作りで、見出し行は表の中をスクロールしても固定される。

export const Flash = styled.p<{ $type: 'success' | 'error' }>`
  margin: 0 0 14px;
  padding: 9px 14px;
  border-radius: 3px;
  font-size: 13px;
  background-color: ${(p) => (p.$type === 'success' ? '#eef6ed' : '#fdf0ee')};
  border: solid 1px ${(p) => (p.$type === 'success' ? '#bcd9b6' : '#e8bdb5')};
  color: ${(p) => (p.$type === 'success' ? '#2f6b26' : '#c0392b')};
`;
export const Count = styled.p`
  margin: 0 0 10px;
  font-size: 14px;
  color: #555;
`;
// 表の中だけをスクロールさせ、見出し行（Th の position: sticky）を常に見えるようにする。
// 横スクロールのために overflow を付けている以上、sticky はこの箱に対して効くため、
// 箱に高さの上限が無いと縦に伸びきってしまい見出しが固定されない。
// 上限は画面の高さからヘッダー・見出し・件数・追加ボタンのぶんを引いたもの
export const Scroll = styled.div`
  overflow: auto;
  max-height: max(320px, calc(100vh - 230px));
  background-color: #fff;
  border: solid 1px #ddd;
  border-radius: 4px;
`;
export const Table = styled.table<{ $minWidth: number }>`
  width: 100%;
  min-width: ${(p) => p.$minWidth}px;
  border-collapse: collapse;
  font-size: 13px;
  table-layout: fixed;
`;
// ツールチップ。
// 親の Th が position: sticky + z-index を持つためスタック文脈を作っており、
// ここの z-index は Th の中でしか効かない（10 と書いても全体には影響しない）。
// 本文（tbody）より前面に出るのは Th 自体の z-index で担保されているので、
// ここは Th 内の兄弟に勝てればよく 1 で足りる。
export const Tip = styled.span<{ $align: 'left' | 'right' }>`
  display: none;
  position: absolute;
  top: calc(100% + 4px);
  ${(p) => (p.$align === 'right' ? 'right: 0;' : 'left: 0;')}
  z-index: 1;
  width: 300px;
  padding: 8px 10px;
  background-color: #333e4d;
  color: #fff;
  border-radius: 3px;
  font-size: 11px;
  line-height: 1.6;
  font-weight: normal;
  text-align: left;
  white-space: pre-line;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
`;
export const Help = styled.span`
  position: relative;
  display: inline-block;
  width: 14px;
  height: 14px;
  margin-left: 3px;
  border-radius: 50%;
  background-color: #dfe6ef;
  color: #3b5d8f;
  font-size: 10px;
  font-weight: bold;
  line-height: 14px;
  text-align: center;
  cursor: help;
  user-select: none;
  vertical-align: middle;

  &:hover {
    background-color: #c9d6e6;
  }
  &:hover ${Tip}, &:focus ${Tip} {
    display: block;
  }
`;
export const Th = styled.th<{ $align?: string }>`
  position: sticky;
  top: 0;
  /* 本文より前面に固定する */
  z-index: 2;
  /* 見出しセルはどれも z-index: 2 なので、同値のときは DOM 順で後ろの列が前面に来る。
     ツールチップの上端は見出しの帯に数px重なるため、そのままだと右隣の見出しに
     隠れて欠ける。ホバー中の列だけ一段上げて全体が見えるようにする。 */
  &:hover {
    z-index: 3;
  }
  box-sizing: border-box;
  background-color: #f5f5f5;
  border-bottom: solid 2px #e0e0e0;
  padding: 8px 8px;
  text-align: ${(p) => p.$align || 'left'};
  font-size: 11px;
  color: #555;
  white-space: nowrap;
  overflow: visible;
`;
export const Td = styled.td<{ $align?: string }>`
  box-sizing: border-box;
  border-bottom: solid 1px #eee;
  padding: 6px 8px;
  text-align: ${(p) => p.$align || 'left'};
  vertical-align: top;
  white-space: pre-line;
  word-break: break-word;
`;
export const Row = styled.tr<{ $editing?: boolean }>`
  background-color: ${(p) => (p.$editing ? '#eef3fa' : 'transparent')};
  &:nth-child(even) {
    background-color: ${(p) => (p.$editing ? '#eef3fa' : '#fafafa')};
  }
`;
export const CellInput = styled(Input)`
  padding: 4px 6px;
  font-size: 12px;
`;
export const CellTextarea = styled.textarea`
  width: 100%;
  box-sizing: border-box;
  padding: 4px 6px;
  border: solid 1px #b3b3b3;
  border-radius: 2px;
  font-size: 12px;
  font-family: inherit;
  resize: vertical;
`;
export const RowActions = styled.div`
  display: flex;
  gap: 5px;
  justify-content: flex-end;

  button {
    padding: 4px 9px;
    font-size: 11px;
    border-width: 1px;
    min-width: 0;
  }
`;
export const ErrorRow = styled.td`
  padding: 6px 10px;
  background-color: #fdf0ee;
  border-bottom: solid 1px #eee;
  color: #c0392b;
  font-size: 12px;
`;
export const AddBar = styled.div`
  margin-top: 12px;

  button {
    padding: 9px 22px;
    font-size: 13px;
  }
`;
export const Muted = styled.span`
  color: #aaa;
`;
export const Stamp = styled.span`
  white-space: nowrap;
`;
export const Loading = styled.div`
  display: flex;
  justify-content: center;
  padding: 60px;
`;
export const ErrorText = styled.p`
  padding: 14px;
  text-align: center;
  color: #c0392b;
`;

// API は UTC の ISO 文字列を返すので、閲覧者のタイムゾーンに直して出す
export const formatDate = (value: string) => {
  if (!value) return '';
  const d = new Date(value);
  const p = (n: number) => String(n).padStart(2, '0');
  return `${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}`;
};
export const formatDateTime = (value: string) => {
  if (!value) return '';
  const d = new Date(value);
  const p = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}`;
};
