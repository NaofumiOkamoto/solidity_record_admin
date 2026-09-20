import { ReactNode, useState } from 'react';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import styled from 'styled-components';
import { FilterOptions } from '../types/product';
import { Button, FieldLabel, Input, PrimaryButton, Select } from './ui';

export type SearchValues = { [key: string]: string };

// 入力欄の種類。
//   text    … 部分一致のテキスト（SKU / discogs_release_id は数値の完全一致）
//   suggest … 実データを入力候補に出すテキスト（部分一致）
//   select  … 実データから作るプルダウン（完全一致。sold_site のみ前方一致）
type FieldKind = 'text' | 'suggest' | 'select';
type FieldDef = { key: string; kind: FieldKind };

// 3カラムのうち1列目。商品を特定するための項目
const IDENTITY_FIELDS: FieldDef[] = [
  { key: 'SKU', kind: 'text' },
  { key: 'artist', kind: 'text' },
  { key: 'title', kind: 'text' },
  { key: 'label', kind: 'text' },
  { key: 'country', kind: 'suggest' },
  { key: 'number', kind: 'text' },
];

// 2列目。分類・状態
const ATTRIBUTE_FIELDS: FieldDef[] = [
  { key: 'genre', kind: 'text' },
  { key: 'format', kind: 'suggest' },
  { key: 'item_condition', kind: 'select' },
  { key: 'sales_status', kind: 'select' },
  { key: 'sold_site', kind: 'select' },
  { key: 'discogs_release_id', kind: 'text' },
];

const NUMBER_RANGE_KEYS = [
  { key: 'release_year', step: '1' },
  { key: 'price_jpy', step: '1' },
  { key: 'price_usd', step: '0.01' },
];

const DATE_RANGE_KEYS = ['registration_date', 'sold_date'];

// 検索条件として URL に載せるキーの一覧。クリア時にまとめて消すのにも使う
export const SEARCH_KEYS: string[] = [
  ...IDENTITY_FIELDS.map(({ key }) => key),
  ...ATTRIBUTE_FIELDS.map(({ key }) => key),
  ...NUMBER_RANGE_KEYS.flatMap(({ key }) => [`${key}_from`, `${key}_to`]),
  ...DATE_RANGE_KEYS.flatMap((key) => [`${key}_from`, `${key}_to`]),
];

const Panel = styled.form`
  background-color: #fff;
  border: solid 1px #ddd;
  border-radius: 4px;
  padding: 16px 20px;
`;
// 検索条件を3カラムに分ける。全17項目を縦6行に収めて、
// 一覧が画面内に入るよう検索エリアの高さを抑えるのが狙い。
// 3列目（範囲条件）は入力欄が2つ並ぶぶん広くとる。
const Columns = styled.div`
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 1fr) minmax(0, 1.35fr);
  gap: 18px 36px;
  align-items: start;

  @media (max-width: 1200px) {
    grid-template-columns: minmax(0, 1fr) minmax(0, 1.35fr);
  }
  @media (max-width: 780px) {
    grid-template-columns: minmax(0, 1fr);
  }
`;
// 1行1項目で縦に積む。ラベルを左に固定幅で置くことで入力欄の左端が揃い、
// 項目名と値をまとめて追いやすくなる。
const FieldList = styled.div`
  display: grid;
  gap: 10px;
  align-content: start;
`;
const FieldRow = styled.div`
  display: grid;
  grid-template-columns: 130px 1fr;
  align-items: center;
  gap: 10px;

  /* 幅が足りないときはラベルを上に逃がす */
  @media (max-width: 600px) {
    grid-template-columns: 1fr;
    gap: 4px;
  }
`;
const RangeRow = styled.div`
  display: flex;
  align-items: center;
  gap: 6px;
  .react-datepicker-wrapper {
    flex: 1;
  }
  /* カレンダーを一覧のヘッダーより前面に出す。
     react-datepicker の既定も一覧ヘッダー（sticky）も z-index: 1 のため、
     そのままだと DOM で後ろにあるヘッダーがカレンダーを覆ってしまう。 */
  .react-datepicker-popper {
    z-index: 20;
  }
`;
const RowLabel = styled(FieldLabel)`
  margin-bottom: 0;
`;
const Tilde = styled.span`
  color: #777;
`;
const Actions = styled.div`
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-top: 18px;

  /* 検索フォームの主操作なので、共通ボタンより一回り大きくする。
     ui.ts の Button 自体は他の画面でも使うためここだけで上書きする。 */
  button {
    min-width: 170px;
    padding: 13px 40px;
    font-size: 15px;
  }
`;

const formatDate = (date: Date | null) => {
  if (!date) return '';
  const y = date.getFullYear();
  const m = ('00' + (date.getMonth() + 1)).slice(-2);
  const d = ('00' + date.getDate()).slice(-2);
  return `${y}-${m}-${d}`;
};

// 'YYYY-MM-DD' をローカル時刻の Date にする（Date.parse だと UTC 扱いで1日ずれる）
const parseDate = (value: string) => (value ? new Date(`${value}T00:00:00`) : null);

type Props = {
  values: SearchValues;
  options: FilterOptions | null;
  onSearch: (values: SearchValues) => void;
  onClear: () => void;
};

export const ProductSearchForm = ({ values, options, onSearch, onClear }: Props) => {
  const [draft, setDraft] = useState<SearchValues>(values);

  const set = (key: string, value: string) => setDraft({ ...draft, [key]: value });

  const submit = (e) => {
    e.preventDefault();
    onSearch(draft);
  };

  const clear = () => {
    setDraft({});
    onClear();
  };

  const layout = (key: string, control: ReactNode) => (
    <FieldRow key={key}>
      <RowLabel htmlFor={`search-${key}`}>{key}</RowLabel>
      {control}
    </FieldRow>
  );

  const textField = (key: string) =>
    layout(
      key,
      <Input
        id={`search-${key}`}
        value={draft[key] || ''}
        onChange={(e) => set(key, e.target.value)}
      />,
    );

  const suggestField = (key: keyof FilterOptions) =>
    layout(
      key,
      <>
        <Input
          id={`search-${key}`}
          list={`options-${key}`}
          value={draft[key] || ''}
          onChange={(e) => set(key, e.target.value)}
        />
        {/* datalist は display:none なのでレイアウトを占有しない */}
        <datalist id={`options-${key}`}>
          {(options?.[key] || []).map((option) => (
            <option key={option.value} value={option.value} />
          ))}
        </datalist>
      </>,
    );

  const selectField = (key: keyof FilterOptions) =>
    layout(
      key,
      <Select
        id={`search-${key}`}
        value={draft[key] || ''}
        onChange={(e) => set(key, e.target.value)}
      >
        <option value="">全て</option>
        {(options?.[key] || []).map((option) => (
          <option key={option.value} value={option.value}>
            {option.value}
          </option>
        ))}
      </Select>,
    );

  const renderField = ({ key, kind }: FieldDef) => {
    if (kind === 'suggest') return suggestField(key as keyof FilterOptions);
    if (kind === 'select') return selectField(key as keyof FilterOptions);
    return textField(key);
  };

  const numberRangeField = (key: string, step: string) => (
    <FieldRow key={key}>
      <RowLabel>{key}</RowLabel>
      <RangeRow>
        <Input
          type="number"
          step={step}
          aria-label={`${key} 下限`}
          value={draft[`${key}_from`] || ''}
          onChange={(e) => set(`${key}_from`, e.target.value)}
        />
        <Tilde>〜</Tilde>
        <Input
          type="number"
          step={step}
          aria-label={`${key} 上限`}
          value={draft[`${key}_to`] || ''}
          onChange={(e) => set(`${key}_to`, e.target.value)}
        />
      </RangeRow>
    </FieldRow>
  );

  const dateRangeField = (key: string) => (
    <FieldRow key={key}>
      <RowLabel>{key}</RowLabel>
      <RangeRow>
        <DatePicker
          selected={parseDate(draft[`${key}_from`] || '')}
          onChange={(date: Date | null) => set(`${key}_from`, formatDate(date))}
          dateFormat="yyyy-MM-dd"
          placeholderText="指定なし"
          isClearable
          customInput={<Input aria-label={`${key} 開始`} />}
        />
        <Tilde>〜</Tilde>
        <DatePicker
          selected={parseDate(draft[`${key}_to`] || '')}
          onChange={(date: Date | null) => set(`${key}_to`, formatDate(date))}
          dateFormat="yyyy-MM-dd"
          placeholderText="指定なし"
          isClearable
          customInput={<Input aria-label={`${key} 終了`} />}
        />
      </RangeRow>
    </FieldRow>
  );

  return (
    <Panel onSubmit={submit}>
      <Columns>
        <FieldList>{IDENTITY_FIELDS.map(renderField)}</FieldList>
        <FieldList>{ATTRIBUTE_FIELDS.map(renderField)}</FieldList>
        <FieldList>
          {NUMBER_RANGE_KEYS.map(({ key, step }) => numberRangeField(key, step))}
          {DATE_RANGE_KEYS.map((key) => dateRangeField(key))}
        </FieldList>
      </Columns>

      <Actions>
        <Button type="button" onClick={clear}>
          クリア
        </Button>
        <PrimaryButton type="submit">検索</PrimaryButton>
      </Actions>
    </Panel>
  );
};
