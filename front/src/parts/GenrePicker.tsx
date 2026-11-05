import { useState } from 'react';
import styled from 'styled-components';
import { Modal, ModalFooter, ModalGroup, ModalGroupTitle, ModalHeader, ModalList, ModalTitle } from './Modal';
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

export const GenrePicker = ({ open, onClose, ...rest }: Props) => (
  <Modal open={open} onClose={onClose}>
    <GenrePickerBody onClose={onClose} {...rest} />
  </Modal>
);

// 開いている間だけ描画される。draft は開くたびに今の値から始まる
const GenrePickerBody = ({ genres, selected, onApply, onClose }: Omit<Props, 'open'>) => {
  const [draft, setDraft] = useState<number[]>(selected);

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
    <>
      <ModalHeader>
        <ModalTitle>ジャンルを選択</ModalTitle>
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
          <Hint>先頭のジャンルでメルカリ・ヤフオクのカテゴリが決まります。新しくチェックしたものは末尾に追加されます</Hint>
        </Selected>
      </ModalHeader>
      <ModalList>
        {Array.from(groups.entries()).map(([main, items]) => (
          <ModalGroup key={main}>
            <ModalGroupTitle>{main}</ModalGroupTitle>
            <Options>
              {items.map((item) => (
                <Option key={item.id}>
                  <input type="checkbox" checked={draft.includes(item.id)} onChange={() => toggle(item.id)} />
                  {item.label}
                </Option>
              ))}
            </Options>
          </ModalGroup>
        ))}
      </ModalList>
      <ModalFooter>
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
      </ModalFooter>
    </>
  );
};
