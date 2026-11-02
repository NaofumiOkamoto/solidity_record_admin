import { useEffect, useRef, useState } from 'react';
import styled from 'styled-components';
import { Button, PrimaryButton } from './ui';
import { GenreOption } from '../types/product';

// ジャンルの複数選択モーダル（docs/03-product-detail.md）。チェックを付け外しし、「反映」で確定する。
// 「キャンセル」・Esc・枠外クリックでは何も変えない。
//
// **ジャンルの並び順には意味がある。** メルカリ・ヤフオクのカテゴリは先頭のジャンルで決まる
// （mercari_helper / yahoo_auction_helper）。そのため選択済みの順番は保ち、新しくチェックしたものは
// チェックした順に末尾へ足す。

type Props = {
  open: boolean;
  genres: GenreOption[];
  selected: number[];
  onApply: (ids: number[]) => void;
  onClose: () => void;
};

// 枠外クリックを拾うため、dialog 自体には余白を付けず中身に付ける
const Dialog = styled.dialog`
  width: min(720px, calc(100vw - 32px));
  max-height: calc(100vh - 64px);
  padding: 0;
  border: none;
  border-radius: 6px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.25);
  &::backdrop {
    background-color: rgba(0, 0, 0, 0.4);
  }
`;
const Body = styled.div`
  display: flex;
  flex-direction: column;
  max-height: calc(100vh - 64px);
`;
const Header = styled.div`
  padding: 16px 20px 12px;
  border-bottom: solid 1px #ddd;
`;
const Title = styled.h2`
  margin: 0;
  font-size: 16px;
`;
const Selected = styled.p`
  margin: 10px 0 0;
  font-size: 13px;
  color: #555;
`;
const Order = styled.span`
  margin-right: 2px;
  font-size: 11px;
  color: #3b5d8f;
`;
const Hint = styled.span`
  display: block;
  margin-top: 4px;
  font-size: 12px;
  color: #999;
`;
const List = styled.div`
  flex: 1;
  overflow-y: auto;
  padding: 8px 20px 16px;
`;
const Group = styled.fieldset`
  margin: 8px 0 0;
  padding: 0;
  border: none;
`;
const GroupTitle = styled.legend`
  padding: 0;
  margin-bottom: 4px;
  font-size: 13px;
  font-weight: bold;
  color: #555;
`;
const Options = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 2px 12px;
`;
const Option = styled.label`
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 3px 0;
  font-size: 14px;
  cursor: pointer;
`;
const Footer = styled.div`
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 12px 20px;
  border-top: solid 1px #ddd;
`;

export const GenrePicker = ({ open, genres, selected, onApply, onClose }: Props) => {
  const dialogRef = useRef<HTMLDialogElement>(null);
  const [draft, setDraft] = useState<number[]>([]);

  // 開くたびに今の値から始める（前回キャンセルした途中の状態は持ち越さない）
  useEffect(() => {
    const dialog = dialogRef.current;
    if (!dialog) return;
    if (open && !dialog.open) {
      setDraft(selected);
      dialog.showModal();
    } else if (!open && dialog.open) {
      dialog.close();
    }
  }, [open, selected]);

  const byId = new Map(genres.map((genre) => [genre.id, genre]));
  const nameOf = (id: number) => byId.get(id)?.sub || `id ${id}（マスタに無し）`;

  const toggle = (id: number) =>
    setDraft((current) => (current.includes(id) ? current.filter((item) => item !== id) : [...current, id]));

  const groups = new Map<string, { id: number; label: string }[]>();
  // マスタに無い id も、外せるように一覧に出す
  const unknown = draft.filter((id) => !byId.has(id));
  if (unknown.length > 0)
    groups.set(
      'マスタに無い id',
      unknown.map((id) => ({ id, label: nameOf(id) })),
    );
  genres.forEach((genre) =>
    groups.set(genre.main, [...(groups.get(genre.main) || []), { id: genre.id, label: genre.sub }]),
  );

  return (
    <Dialog
      ref={dialogRef}
      // Esc で閉じたとき
      onCancel={(e) => {
        e.preventDefault();
        onClose();
      }}
      onClick={(e) => e.target === dialogRef.current && onClose()}
    >
      {open && (
        <Body>
          <Header>
            <Title>ジャンルを選択</Title>
            <Selected>
              選択中（{draft.length}）:{' '}
              {draft.length === 0
                ? 'なし'
                : draft.map((id, index) => (
                    <span key={id}>
                      {index > 0 && '、'}
                      <Order>{index + 1}.</Order>
                      {nameOf(id)}
                    </span>
                  ))}
              <Hint>
                先頭のジャンルでメルカリ・ヤフオクのカテゴリが決まります。新しくチェックしたものは末尾に追加されます
              </Hint>
            </Selected>
          </Header>
          <List>
            {Array.from(groups.entries()).map(([main, items]) => (
              <Group key={main}>
                <GroupTitle>{main}</GroupTitle>
                <Options>
                  {items.map((item) => (
                    <Option key={item.id}>
                      <input type="checkbox" checked={draft.includes(item.id)} onChange={() => toggle(item.id)} />
                      {item.label}
                    </Option>
                  ))}
                </Options>
              </Group>
            ))}
          </List>
          <Footer>
            <Button type="button" onClick={onClose}>
              キャンセル
            </Button>
            <PrimaryButton
              type="button"
              onClick={() => {
                onApply(draft);
                onClose();
              }}
            >
              反映
            </PrimaryButton>
          </Footer>
        </Body>
      )}
    </Dialog>
  );
};
