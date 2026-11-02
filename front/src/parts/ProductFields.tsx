import { useState } from 'react';
import styled from 'styled-components';
import { GenrePicker } from './GenrePicker';
import { Button, FieldLabel, Input, Select } from './ui';
import { FilterOptions, ProductDetail } from '../types/product';

// 商品の入力欄一式（docs/03-product-detail.md）。詳細兼編集（/products/:sku）と、
// 今後の商品登録（/products/new・04）で共通に使う。値と変更処理は呼び出し側が持つ。
//
// 項目の並びは docs/90-field-reference.md のセクション1〜3（商品登録モックの左・中・右列）。
// ただし左列は「Discogs 読込で埋まる項目」とそれ以外に分け、読込ボタンを埋まる項目の真上に置く。
// 値は DB のまま扱う（グレードの "VG_VG+" など）。スプレッドシートで入力するのと同じ形にそろえるため。

// フォームの値はすべて文字列で持つ。数値欄に "abc" と打たれても消さずに API へ送り、
// API の入力チェックでエラーを返させる（画面で弾くと、何が悪いのか利用者に伝わらない）
export type FormValues = { [key: string]: string };
export type FormErrors = { [key: string]: string[] };

type Kind =
  | 'text'
  | 'integer'
  | 'decimal'
  | 'textarea'
  | 'link'
  | 'date'
  | 'genre'
  // 候補から選ぶが、候補に無い値も入力できる
  | 'combo'
  // 候補からのみ選ぶ
  | 'select';

export type Field = {
  key: keyof ProductDetail;
  kind?: Kind;
  // 選択肢。options（実データ）から引く列名か、固定の候補
  choices?: keyof FilterOptions | readonly string[];
  // 編集可能な画面でも入力させない
  readOnly?: boolean;
  // 入力欄の下に出す説明（編集できるときだけ）
  hint?: string;
};

const GRADES = ['M', 'NM', 'EX+', 'EX', 'EX-', 'VG+', 'VG', 'VG-', 'G+', 'G'] as const;
const ITEM_CONDITIONS = ['New', 'Used'] as const;

type Section = {
  title: string;
  note?: string;
  discogs?: boolean;
  // 値が入っている項目だけ出す。1つも無ければパネルごと出さない
  onlyFilled?: boolean;
  fields: Field[];
};

// 3列。各列に縦にパネルを積む
const COLUMNS: Section[][] = [
  [
    {
      title: 'Discogs から取得',
      note: '「読込」で discogs_release_id から自動入力される項目',
      discogs: true,
      // 90 の Discogs 読込マッピングのうち、フォームに載る項目。
      // genre は Discogs のジャンル体系と1対1に対応しないので含めない（手で選ぶ）
      fields: [
        { key: 'discogs_release_id', kind: 'integer' },
        { key: 'artist' },
        { key: 'title' },
        { key: 'label' },
        { key: 'country', kind: 'combo', choices: 'country' },
        { key: 'number' },
        { key: 'release_year', kind: 'integer' },
        { key: 'format', kind: 'combo', choices: 'format' },
      ],
    },
    {
      title: '基本情報',
      fields: [
        // SKU は商品画像・試聴音源のファイル名や Shopify の Handle に使われており、変えると影響が大きい。
        // 通常の入力欄では変えさせず、専用の操作を用意する（docs/03「SKU の変更」。未実装）
        { key: 'SKU', readOnly: true },
        { key: 'genre', kind: 'genre' },
        { key: 'item_condition', kind: 'select', choices: ITEM_CONDITIONS },
      ],
    },
  ],
  [
    {
      title: 'コンディション・メディア',
      fields: [
        { key: 'record_grading', kind: 'combo', choices: GRADES },
        { key: 'cover_grading', kind: 'combo', choices: GRADES },
        { key: 'record_description_jp', kind: 'textarea' },
        { key: 'record_description_en', kind: 'textarea' },
        { key: 'cover_description_jp', kind: 'textarea' },
        { key: 'cover_description_en', kind: 'textarea' },
        { key: 'mp3_A', kind: 'link' },
        { key: 'mp3_B', kind: 'link' },
        { key: 'weight', kind: 'integer' },
        { key: 'img_count', kind: 'integer' },
      ],
    },
  ],
  [
    {
      title: '価格・在庫・ステータス',
      fields: [
        { key: 'price_jpy', kind: 'integer' },
        { key: 'price_usd', kind: 'decimal' },
        { key: 'cost_price' },
        { key: 'quantity', kind: 'integer' },
        { key: 'registration_date', kind: 'date' },
        { key: 'sold_date', kind: 'date', hint: '入力すると sales_status を Sold Out、quantity を 0 にします' },
        // yahoo_auction_2 のような連番付きの値があるので、候補に無い値も入れられるようにする
        { key: 'sold_site', kind: 'combo', choices: 'sold_site' },
        { key: 'sales_status', kind: 'combo', choices: 'sales_status' },
      ],
    },
    {
      // 編集できるようになってもフォームでは触らせない項目。
      // recoding_date / track_list / personnel は eBay の商品説明にだけ出る（99 B-1 で登録フォーム不要と確定）。
      // discogs_listing_id は Discogs API から書き戻す列で、人が触ってはいけない（90 参照）
      title: 'その他の情報（この画面では編集しない）',
      onlyFilled: true,
      fields: [
        { key: 'recoding_date', readOnly: true },
        { key: 'track_list', kind: 'textarea', readOnly: true },
        { key: 'personnel', kind: 'textarea', readOnly: true },
        { key: 'discogs_listing_id', readOnly: true },
      ],
    },
  ],
];

// フォームで扱う列（読み取り専用の項目を除く）。API の Product::EDITABLE_COLUMNS と対応する
export const EDITABLE_KEYS: string[] = COLUMNS.flat()
  .flatMap((section) => section.fields)
  .filter((field) => !field.readOnly)
  .map((field) => field.key);

export const toFormValues = (product: ProductDetail): FormValues => {
  const values: FormValues = {};
  Object.entries(product).forEach(([key, value]) => {
    values[key] = value == null ? '' : String(value);
  });
  return values;
};

// "2_10" → [2, 10]
const parseGenreIds = (value: string) =>
  value
    .split('_')
    .filter((id) => /^\d+$/.test(id))
    .map(Number);

const Columns = styled.div`
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
  align-items: start;
  @media (max-width: 1199px) {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
  @media (max-width: 779px) {
    grid-template-columns: minmax(0, 1fr);
  }
`;
const Column = styled.div`
  display: flex;
  flex-direction: column;
  gap: 16px;
`;
export const Panel = styled.section`
  background-color: #fff;
  border: solid 1px #ddd;
  border-radius: 4px;
  padding: 12px 16px;
`;
// Discogs で埋まる項目のまとまり。他のパネルと区別できるよう枠と背景の色を変える
const DiscogsPanel = styled(Panel)`
  border-color: #b2cbf3;
  background-color: #f6f9fe;
`;
export const PanelTitle = styled.h3`
  margin: 0 0 12px;
  font-size: 14px;
  color: #555;
`;
const PanelNote = styled.p`
  margin: -6px 0 12px;
  font-size: 12px;
  color: #777;
`;
export const Fields = styled.div`
  display: flex;
  flex-direction: column;
  gap: 10px;
`;
const InlineRow = styled.div`
  display: flex;
  align-items: center;
  gap: 8px;
`;
const ReleaseIdRow = styled.div`
  display: flex;
  align-items: flex-end;
  gap: 8px;
  & > :first-child {
    flex: 1;
  }
`;
const LoadButton = styled(Button)`
  flex-shrink: 0;
  padding: 6px 14px;
`;
const OpenLink = styled.a`
  flex-shrink: 0;
  font-size: 13px;
  color: #3b5d8f;
`;
// 読み取り専用でも値は選択してコピーできるよう、disabled ではなく readOnly にする。
// 入力できそうに見えないよう背景だけ落とす
const TextInput = styled(Input)<{ $invalid?: boolean }>`
  ${(p) => (p.$invalid ? 'border-color: #c0392b;' : '')}
  &:read-only {
    background-color: #f7f7f7;
    color: #222;
  }
`;
const TextArea = styled.textarea<{ $invalid?: boolean }>`
  width: 100%;
  box-sizing: border-box;
  padding: 6px 8px;
  border: solid 1px ${(p) => (p.$invalid ? '#c0392b' : '#b3b3b3')};
  border-radius: 2px;
  font-size: 14px;
  font-family: inherit;
  resize: vertical;
  &:read-only {
    background-color: #f7f7f7;
    color: #222;
  }
`;
const SelectInput = styled(Select)<{ $invalid?: boolean }>`
  ${(p) => (p.$invalid ? 'border-color: #c0392b;' : '')}
`;
const Hint = styled.p`
  margin: 4px 0 0;
  font-size: 12px;
  color: #777;
`;
const ErrorText = styled.p`
  margin: 4px 0 0;
  font-size: 12px;
  color: #c0392b;
`;
// 変更した項目の目印
const Changed = styled.span`
  margin-left: 6px;
  font-size: 11px;
  color: #b07d12;
`;
const Chips = styled.div`
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 6px;
`;
const Chip = styled.span`
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 2px 4px 2px 10px;
  border-radius: 12px;
  background-color: #eef3fa;
  font-size: 13px;
`;
const ChipRemove = styled.button`
  border: none;
  background: none;
  padding: 0 4px;
  font-size: 14px;
  color: #777;
  cursor: pointer;
  &:hover {
    color: #c0392b;
  }
`;
const PickButton = styled(Button)<{ $invalid?: boolean }>`
  padding: 6px 14px;
  font-weight: normal;
  font-size: 13px;
  ${(p) => (p.$invalid ? 'border-color: #c0392b;' : '')}
`;
const Placeholder = styled.span`
  font-size: 13px;
  color: #bbb;
`;

type Props = {
  values: FormValues;
  // 読み込んだ時点の値。変更した項目に目印を付けるために使う
  initialValues: FormValues;
  errors: FormErrors;
  options: FilterOptions | null;
  editable: boolean;
  onChange: (key: string, value: string) => void;
};

export const ProductFields = ({ values, initialValues, errors, options, editable, onChange }: Props) => {
  const genres = options?.genres || [];
  const [genrePickerOpen, setGenrePickerOpen] = useState(false);

  const choicesOf = (field: Field): string[] => {
    if (!field.choices) return [];
    if (typeof field.choices !== 'string') return [...field.choices];
    const list = options?.[field.choices];
    return Array.isArray(list) ? (list as { value?: string }[]).map((item) => item.value || '').filter(Boolean) : [];
  };

  const genreName = (id: number) => {
    const genre = genres.find((item) => item.id === id);
    // マスタに無い id も黙って捨てず、あることが分かるように出す
    return genre ? genre.sub : `id ${id}（マスタに無し）`;
  };

  const renderGenre = (field: Field, id: string, readOnly: boolean, invalid: boolean) => {
    const ids = parseGenreIds(values.genre || '');
    if (readOnly) {
      return <TextInput id={id} value={ids.map(genreName).join('、')} readOnly />;
    }
    const setIds = (next: number[]) => onChange(field.key, next.join('_'));
    return (
      <>
        <Chips>
          {ids.length === 0 && <Placeholder>未選択</Placeholder>}
          {ids.map((genreId) => (
            <Chip key={genreId}>
              {genreName(genreId)}
              <ChipRemove
                type="button"
                aria-label={`${genreName(genreId)} を外す`}
                onClick={() => setIds(ids.filter((item) => item !== genreId))}
              >
                ×
              </ChipRemove>
            </Chip>
          ))}
        </Chips>
        <PickButton id={id} type="button" $invalid={invalid} onClick={() => setGenrePickerOpen(true)}>
          ジャンルを選択…
        </PickButton>
        <GenrePicker
          open={genrePickerOpen}
          genres={genres}
          selected={ids}
          onApply={setIds}
          onClose={() => setGenrePickerOpen(false)}
        />
      </>
    );
  };

  const renderControl = (field: Field) => {
    const id = `product-${field.key}`;
    const value = values[field.key] ?? '';
    const readOnly = !editable || !!field.readOnly;
    const invalid = !!errors[field.key];
    const change = (next: string) => {
      onChange(field.key, next);
      // 売れた日を入れたら在庫を落とす（クライアント依頼）。日付を消したときは戻さない。
      // 戻すべき値（売れる前の quantity）が分からず、取り消しは「元に戻す」で足りるため
      if (field.key === 'sold_date' && next) {
        onChange('sales_status', 'Sold Out');
        onChange('quantity', '0');
      }
    };
    const listId = `${id}-choices`;

    switch (field.kind) {
      case 'genre':
        return renderGenre(field, id, readOnly, invalid);
      case 'textarea':
        return (
          <TextArea
            id={id}
            value={value}
            rows={3}
            readOnly={readOnly}
            $invalid={invalid}
            onChange={(e) => change(e.target.value)}
          />
        );
      case 'link':
        return (
          <InlineRow>
            <TextInput id={id} value={value} readOnly={readOnly} $invalid={invalid} onChange={(e) => change(e.target.value)} />
            {value && (
              <OpenLink href={value} target="_blank" rel="noreferrer">
                開く
              </OpenLink>
            )}
          </InlineRow>
        );
      case 'select': {
        if (readOnly) return <TextInput id={id} value={value} readOnly />;
        const choices = choicesOf(field);
        return (
          <SelectInput id={id} value={value} $invalid={invalid} onChange={(e) => change(e.target.value)}>
            <option value="">（未選択）</option>
            {/* 既存データに候補外の値が入っていても、消さずに見えるようにする */}
            {value && !choices.includes(value) && <option value={value}>{value}</option>}
            {choices.map((choice) => (
              <option key={choice} value={choice}>
                {choice}
              </option>
            ))}
          </SelectInput>
        );
      }
      case 'combo':
        return (
          <>
            <TextInput
              id={id}
              value={value}
              readOnly={readOnly}
              $invalid={invalid}
              list={readOnly ? undefined : listId}
              autoComplete="off"
              onChange={(e) => change(e.target.value)}
            />
            {!readOnly && (
              <datalist id={listId}>
                {choicesOf(field).map((choice) => (
                  <option key={choice} value={choice} />
                ))}
              </datalist>
            )}
          </>
        );
      case 'date':
        return (
          <TextInput
            id={id}
            type={readOnly ? 'text' : 'date'}
            value={value}
            readOnly={readOnly}
            $invalid={invalid}
            onChange={(e) => change(e.target.value)}
          />
        );
      default:
        return (
          <TextInput
            id={id}
            value={value}
            readOnly={readOnly}
            $invalid={invalid}
            inputMode={field.kind === 'integer' ? 'numeric' : field.kind === 'decimal' ? 'decimal' : undefined}
            onChange={(e) => change(e.target.value)}
          />
        );
    }
  };

  const renderField = (field: Field) => (
    <div key={field.key}>
      <FieldLabel htmlFor={`product-${field.key}`}>
        {field.key}
        {editable && (values[field.key] ?? '') !== (initialValues[field.key] ?? '') && <Changed>変更あり</Changed>}
      </FieldLabel>
      {renderControl(field)}
      {editable && field.hint && <Hint>{field.hint}</Hint>}
      {errors[field.key]?.map((message) => (
        <ErrorText key={message}>
          {field.key}
          {message}
        </ErrorText>
      ))}
    </div>
  );

  return (
    <Columns>
      {COLUMNS.map((sections) => (
        <Column key={sections[0].title}>
          {sections.map((section) => {
            const SectionPanel = section.discogs ? DiscogsPanel : Panel;
            const fields = section.onlyFilled ? section.fields.filter((field) => initialValues[field.key]) : section.fields;
            if (fields.length === 0) return null;
            return (
              <SectionPanel key={section.title}>
                <PanelTitle>{section.title}</PanelTitle>
                {section.note && <PanelNote>{section.note}</PanelNote>}
                <Fields>
                  {fields.map((field) =>
                    field.key === 'discogs_release_id' ? (
                      <ReleaseIdRow key={field.key}>
                        {renderField(field)}
                        {/* GET /api/discogs/releases/:id ができるまで押せない（docs/03 の「Discogs 読込」） */}
                        <LoadButton type="button" disabled title="準備中">
                          読込
                        </LoadButton>
                      </ReleaseIdRow>
                    ) : (
                      renderField(field)
                    ),
                  )}
                </Fields>
              </SectionPanel>
            );
          })}
        </Column>
      ))}
    </Columns>
  );
};
