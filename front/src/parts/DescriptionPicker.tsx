import { useState } from 'react';
import styled from 'styled-components';
import { Modal, ModalFooter, ModalGroup, ModalGroupTitle, ModalHeader, ModalList, ModalTitle } from './Modal';
import { Button, PrimaryButton } from './ui';
import {
  applyTemplates,
  DESCRIPTION_TEMPLATES,
  DescriptionTarget,
  DescriptionTemplate,
  usedTemplateIds,
} from '../lib/descriptionTemplates';

// 説明文の定型文モーダル（docs/03-product-detail.md）。チェックした定型文で日本語・英語の説明文を作り、
// 「反映」で両方の欄に入れる。「キャンセル」・Esc・枠外クリックでは何も変えない。
//
// 開いたときは、今の説明文に含まれている定型文にチェックが付いた状態から始まる。
// 反映すると定型文の部分だけが入れ替わり、手で書いた文は後ろにそのまま残る。
//
// 閲覧のみの画面（readOnly）でも開ける。チェックとプレビューはできるが、「反映」は出さない。
// 本番で操作のイメージを見てもらうため（2026-11-05）。

type Props = {
  open: boolean;
  target: DescriptionTarget;
  // 閲覧のみ。「反映」を出さない
  readOnly?: boolean;
  jp: string;
  en: string;
  onApply: (next: { jp: string; en: string }) => void;
  onClose: () => void;
};

const TITLES: { [key in DescriptionTarget]: string } = {
  record: '盤の説明文（record_description）を定型文から作る',
  cover: 'ジャケットの説明文（cover_description）を定型文から作る',
};

const Notice = styled.p`
  margin: 6px 0 0;
  font-size: 12px;
  color: #b07d12;
`;
const Option = styled.label`
  display: flex;
  align-items: baseline;
  gap: 8px;
  padding: 4px 0;
  font-size: 14px;
  cursor: pointer;
  & input {
    flex-shrink: 0;
    transform: translateY(1px);
  }
`;
const En = styled.span`
  display: block;
  font-size: 12px;
  color: #888;
`;
const Note = styled.span`
  margin-left: 6px;
  font-size: 11px;
  color: #3b5d8f;
`;
const Preview = styled.div`
  padding: 10px 20px;
  border-top: solid 1px #ddd;
  background-color: #fafafa;
  font-size: 13px;
`;
const PreviewRow = styled.p`
  margin: 2px 0;
  & > span:first-child {
    display: inline-block;
    width: 64px;
    color: #777;
    font-size: 12px;
  }
`;
const Manual = styled.p`
  margin: 6px 0 0;
  font-size: 12px;
  color: #777;
`;

export const DescriptionPicker = ({ open, onClose, ...rest }: Props) => (
  <Modal open={open} onClose={onClose}>
    <DescriptionPickerBody onClose={onClose} {...rest} />
  </Modal>
);

// 開いている間だけ描画される。チェックは開くたびに今の説明文から作り直す
const DescriptionPickerBody = ({ target, readOnly, jp, en, onApply, onClose }: Omit<Props, 'open'>) => {
  const templates = DESCRIPTION_TEMPLATES.filter((template) => template.target === target);
  const [checked, setChecked] = useState<string[]>(() => usedTemplateIds(templates, jp));

  const toggle = (id: string) =>
    setChecked((current) => (current.includes(id) ? current.filter((item) => item !== id) : [...current, id]));

  const result = applyTemplates(templates, { jp, en }, checked);

  const groups = new Map<string, DescriptionTemplate[]>();
  templates.forEach((template) => groups.set(template.category, [...(groups.get(template.category) || []), template]));

  return (
    <>
      <ModalHeader>
        <ModalTitle>{TITLES[target]}</ModalTitle>
        <Notice>
          定型文は操作のイメージ用の仮のものです。
          {readOnly && '閲覧のみのため、チェックして反映後の文を確かめるところまでで、欄には反映できません。'}
        </Notice>
      </ModalHeader>
      <ModalList>
        {Array.from(groups.entries()).map(([category, items]) => (
          <ModalGroup key={category}>
            <ModalGroupTitle>{category}</ModalGroupTitle>
            {items.map((template) => (
              <Option key={template.id}>
                <input type="checkbox" checked={checked.includes(template.id)} onChange={() => toggle(template.id)} />
                <span>
                  {template.jp}
                  {template.note && <Note>（{template.note}）</Note>}
                  <En>{template.en}</En>
                </span>
              </Option>
            ))}
          </ModalGroup>
        ))}
      </ModalList>
      <Preview>
        <PreviewRow>
          <span>日本語</span>
          {result.jp || '（空）'}
        </PreviewRow>
        <PreviewRow>
          <span>英語</span>
          {result.en || '（空）'}
        </PreviewRow>
        {result.manualJp.length > 0 && (
          <Manual>定型文に無い文はそのまま後ろに残ります: {result.manualJp.join('')}</Manual>
        )}
      </Preview>
      <ModalFooter>
        <Button type="button" onClick={onClose}>
          {readOnly ? '閉じる' : 'キャンセル'}
        </Button>
        {!readOnly && (
          <PrimaryButton
            type="button"
            onClick={() => {
              onApply({ jp: result.jp, en: result.en });
              onClose();
            }}
          >
            反映
          </PrimaryButton>
        )}
      </ModalFooter>
    </>
  );
};
