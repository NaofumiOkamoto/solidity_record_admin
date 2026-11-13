import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import styled from 'styled-components';
import {
  EMPTY_TEMPLATE_FILTER,
  isFiltering,
  matchesTemplate,
  TemplateFilter,
  TemplateFilterValues,
} from './TemplateFilter';
import { Modal, ModalFooter, ModalGroup, ModalGroupTitle, ModalHeader, ModalList, ModalTitle } from './Modal';
import { Button, PrimaryButton } from './ui';
import { api } from '../lib/api';
import {
  applyTemplates,
  DescriptionTarget,
  DescriptionTemplate,
  hasSide,
  SIDE_EN,
  SIDE_JP,
  SIDES,
  TemplateVariant,
  usedVariantKeys,
  variantsOf,
} from '../lib/descriptionTemplates';

// 説明文の定型文モーダル（docs/03-product-detail.md）。チェックした定型文で日本語・英語の説明文を作り、
// 「反映」で両方の欄に入れる。「キャンセル」・Esc・枠外クリックでは何も変えない。
//
// 定型文は開くたびに API から読む（「定型文」画面で直したものがすぐ使えるように）。
// 開いたときは、今の説明文に含まれている定型文にチェックが付いた状態から始まる。
// 反映すると定型文の部分だけが入れ替わり、手で書いた文は後ろにそのまま残る。
//
// 閲覧のみの画面（readOnly）でも開ける。チェックとプレビューはできるが、「反映」は出さない。

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
const MasterLink = styled.p`
  margin: 6px 0 0;
  font-size: 12px;
`;
const Message = styled.p<{ $error?: boolean }>`
  margin: 12px 0;
  font-size: 13px;
  color: ${(p) => (p.$error ? '#c0392b' : '#888')};
`;
// 1行 = 定型文1件。左にチェック、右に文。
// 面を選べる定型文があるモーダルでは、チェックと文の間に面のプルダウンの列をとる。プルダウンはチェックを
// 入れた行にだけ出し、列の幅は常にとっておく（出し入れで文の書き出しがずれないように）
const Row = styled.label<{ $withSides: boolean }>`
  display: grid;
  grid-template-columns: ${(p) => (p.$withSides ? '18px 72px' : '18px')} 1fr;
  gap: 8px;
  align-items: baseline;
  padding: 4px 0;
  font-size: 14px;
  cursor: pointer;
  & > input[type='checkbox'] {
    width: 18px;
    height: 18px;
    margin: 0;
    /* 文の1行目と高さを合わせる */
    align-self: start;
    margin-top: 1px;
  }
`;
const SideSelect = styled.select`
  width: 72px;
  padding: 1px 2px;
  border: solid 1px #3b5d8f;
  border-radius: 3px;
  background-color: #eef3fa;
  font-size: 12px;
`;
const Placeholder = styled.span`
  color: #3b5d8f;
  font-weight: bold;
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
const ModalFilter = styled(TemplateFilter)`
  margin-top: 10px;
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

// チェックを入れたときの面は A面（variantsOf は A面 → B面 → 両面の順。面の無い定型文は1つだけ）
const defaultVariant = (variants: TemplateVariant[]) => variants[0];

// {面} / {side} を目立つ表示に置き換えて出す
const withPlaceholder = (text: string, placeholder: string, label: string) =>
  text
    .split(placeholder)
    .flatMap((part, index) => (index === 0 ? [part] : [<Placeholder key={index}>{label}</Placeholder>, part]));

export const DescriptionPicker = ({ open, onClose, ...rest }: Props) => (
  <Modal open={open} onClose={onClose}>
    <DescriptionPickerBody onClose={onClose} {...rest} />
  </Modal>
);

// 開いている間だけ描画される。開くたびに定型文を読み直し、チェックを今の説明文から作り直す
const DescriptionPickerBody = (props: Omit<Props, 'open'>) => {
  const [templates, setTemplates] = useState<DescriptionTemplate[] | null>(null);
  const [loadError, setLoadError] = useState(false);

  useEffect(() => {
    api
      .get<{ description_templates: DescriptionTemplate[] }>('/api/description_templates')
      .then((res) => setTemplates(res.data.description_templates.filter((t) => t.target === props.target)))
      .catch((e) => {
        console.log('e', e);
        setLoadError(true);
      });
  }, [props.target]);

  if (!templates) {
    return (
      <>
        <ModalHeader>
          <ModalTitle>{TITLES[props.target]}</ModalTitle>
        </ModalHeader>
        <ModalList>
          <Message $error={loadError}>
            {loadError ? '定型文の取得に失敗しました。時間をおいて再度お試しください。' : '読み込み中…'}
          </Message>
        </ModalList>
        <ModalFooter>
          <Button type="button" onClick={props.onClose}>
            閉じる
          </Button>
        </ModalFooter>
      </>
    );
  }
  return <TemplateChecks templates={templates} {...props} />;
};

// チェックの初期値は今の説明文から決めるので、定型文を読み終えてから描画する
const TemplateChecks = ({
  templates,
  target,
  readOnly,
  jp,
  en,
  onApply,
  onClose,
}: Omit<Props, 'open'> & { templates: DescriptionTemplate[] }) => {
  // チェックは面ごと（面を選べる定型文なら「id:A」「id:B」「id:both」、それ以外は「id」）
  const [checked, setChecked] = useState<string[]>(() => usedVariantKeys(templates, jp));

  // チェックは定型文ごとに1つ。面を選べる定型文は、どの面かをプルダウンで選ぶ（A面とB面の両方なら「両面」）。
  // key は面ごと（「id:A」「id:B」「id:both」、面の無い定型文は「id」）なので、同じ定型文の他の面を外してから入れる
  const templateOf = (key: string) => key.split(':')[0];
  const check = (key: string) =>
    setChecked((current) => [...current.filter((item) => templateOf(item) !== templateOf(key)), key]);
  const uncheckTemplate = (template: DescriptionTemplate) =>
    setChecked((current) => current.filter((item) => templateOf(item) !== String(template.id)));

  const result = applyTemplates(templates, { jp, en }, checked);

  // 面を選べる定型文が1つも無ければ（ジャケットなど）、チェックの列は細くする
  const withSides = templates.some(hasSide);

  // 絞り込み。絞り込みで隠れた定型文のチェックはそのまま残り、プレビューと反映にも入る
  const [filter, setFilter] = useState<TemplateFilterValues>(EMPTY_TEMPLATE_FILTER);
  const categories = Array.from(new Set(templates.map((template) => template.category)));
  const shown = templates.filter((template) => matchesTemplate(template, filter));

  const groups = new Map<string, DescriptionTemplate[]>();
  shown.forEach((template) => groups.set(template.category, [...(groups.get(template.category) || []), template]));

  return (
    <>
      <ModalHeader>
        <ModalTitle>{TITLES[target]}</ModalTitle>
        {readOnly && (
          <Notice>閲覧のみのため、チェックして反映後の文を確かめるところまでで、欄には反映できません。</Notice>
        )}
        <MasterLink>
          {/* 別タブで開く。この画面の入力途中の内容を失わないように */}
          <Link to="/description-templates" target="_blank" rel="noopener">
            定型文を追加・編集する
          </Link>
          （別タブで開きます。直したら、このモーダルを開き直すと反映されます）
        </MasterLink>
        <ModalFilter values={filter} categories={categories} onChange={setFilter} />
      </ModalHeader>
      <ModalList>
        {templates.length === 0 && <Message>定型文がまだありません。</Message>}
        {templates.length > 0 && shown.length === 0 && <Message>条件に合う定型文がありません。</Message>}
        {isFiltering(filter) && shown.length > 0 && (
          <Message>
            {shown.length}件（全{templates.length}件）。絞り込みで隠れた定型文のチェックも反映されます。
          </Message>
        )}
        {Array.from(groups.entries()).map(([category, items]) => (
          <ModalGroup key={category}>
            <ModalGroupTitle>{category}</ModalGroupTitle>
            {items.map((template) => {
              const text = (
                <span>
                  {withPlaceholder(template.jp, SIDE_JP, '〇面')}
                  {template.note && <Note>（{template.note}）</Note>}
                  <En>
                    {withPlaceholder(template.en, SIDE_EN, 'A / B side')}
                    {template.en_both && ` ／ ${template.en_both}`}
                  </En>
                </span>
              );
              const variants = variantsOf(template);
              const checkedVariant = variants.find((variant) => checked.includes(variant.key));
              return (
                <Row key={template.id} $withSides={withSides}>
                  <input
                    type="checkbox"
                    checked={!!checkedVariant}
                    onChange={() => (checkedVariant ? uncheckTemplate(template) : check(defaultVariant(variants).key))}
                  />
                  {withSides && (
                    <span>
                      {hasSide(template) && checkedVariant && (
                        <SideSelect
                          value={checkedVariant.key}
                          // 行全体が label だが、プルダウンは操作できる要素なので、触ってもチェックは切り替わらない
                          aria-label="面"
                          onChange={(e) => check(e.target.value)}
                        >
                          {variants.map((variant) => (
                            <option key={variant.key} value={variant.key}>
                              {SIDES.find((side) => side.value === variant.side)?.jp}
                            </option>
                          ))}
                        </SideSelect>
                      )}
                    </span>
                  )}
                  {text}
                </Row>
              );
            })}
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
