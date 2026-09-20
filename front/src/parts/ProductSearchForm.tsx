import { useState } from 'react';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import styled from 'styled-components';
import { FilterOptions } from '../types/product';
import { Button, FieldLabel, Input, PrimaryButton, Select } from './ui';

export type SearchValues = { [key: string]: string };

// 初期表示で展開しておく条件（使用頻度が高いもの）
const BASIC_TEXT_KEYS = ['artist', 'title', 'label'];

// 「詳細条件を開く」で表示する条件
const DETAIL_TEXT_KEYS = ['number', 'genre', 'discogs_release_id'];

// 実データから選択肢を補完するテキスト入力。
// 候補を出しつつ自由入力も許すため、プルダウンではなく datalist を使う。
const SUGGEST_KEYS: Array<keyof FilterOptions> = ['country', 'format'];

// 完全一致のプルダウン（sold_site のみ前方一致）
const SELECT_KEYS: Array<keyof FilterOptions> = ['item_condition', 'sales_status', 'sold_site'];

const NUMBER_RANGE_KEYS = [
  { key: 'release_year', step: '1' },
  { key: 'price_jpy', step: '1' },
  { key: 'price_usd', step: '0.01' },
];

const DATE_RANGE_KEYS = ['registration_date', 'sold_date'];

// 検索条件として URL に載せるキーの一覧。クリア時にまとめて消すのにも使う
export const SEARCH_KEYS: string[] = [
  ...BASIC_TEXT_KEYS,
  ...DETAIL_TEXT_KEYS,
  ...SUGGEST_KEYS,
  ...SELECT_KEYS,
  ...NUMBER_RANGE_KEYS.flatMap(({ key }) => [`${key}_from`, `${key}_to`]),
  ...DATE_RANGE_KEYS.flatMap((key) => [`${key}_from`, `${key}_to`]),
];

// 詳細条件に値が入っていれば、開いた状態で表示する
export const hasDetailCondition = (values: SearchValues) =>
  SEARCH_KEYS.filter((key) => !BASIC_TEXT_KEYS.includes(key)).some((key) => !!values[key]);

const Panel = styled.form`
  background-color: #fff;
  border: solid 1px #ddd;
  border-radius: 4px;
  padding: 20px;
`;
const Grid = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 14px 20px;
`;
const DetailSection = styled.div`
  margin-top: 18px;
  padding-top: 18px;
  border-top: dashed 1px #ddd;
`;
const SectionTitle = styled.p`
  margin: 0 0 12px;
  font-size: 12px;
  font-weight: bold;
  color: #777;
`;
const RangeRow = styled.div`
  display: flex;
  align-items: center;
  gap: 6px;
  .react-datepicker-wrapper {
    flex: 1;
  }
`;
const Tilde = styled.span`
  color: #777;
`;
const Toggle = styled.button`
  margin-top: 16px;
  background: none;
  border: none;
  padding: 0;
  color: #3b5d8f;
  font-size: 14px;
  cursor: pointer;
  &:hover {
    text-decoration: underline;
  }
`;
const Actions = styled.div`
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 20px;
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
  const [detailOpen, setDetailOpen] = useState(hasDetailCondition(values));

  const set = (key: string, value: string) => setDraft({ ...draft, [key]: value });

  const submit = (e) => {
    e.preventDefault();
    onSearch(draft);
  };

  const clear = () => {
    setDraft({});
    onClear();
  };

  const textField = (key: string) => (
    <div key={key}>
      <FieldLabel htmlFor={`search-${key}`}>{key}</FieldLabel>
      <Input
        id={`search-${key}`}
        value={draft[key] || ''}
        onChange={(e) => set(key, e.target.value)}
      />
    </div>
  );

  const suggestField = (key: keyof FilterOptions) => (
    <div key={key}>
      <FieldLabel htmlFor={`search-${key}`}>{key}</FieldLabel>
      <Input
        id={`search-${key}`}
        list={`options-${key}`}
        value={draft[key] || ''}
        onChange={(e) => set(key, e.target.value)}
      />
      <datalist id={`options-${key}`}>
        {(options?.[key] || []).map((option) => (
          <option key={option.value} value={option.value} />
        ))}
      </datalist>
    </div>
  );

  const selectField = (key: keyof FilterOptions) => (
    <div key={key}>
      <FieldLabel htmlFor={`search-${key}`}>{key}</FieldLabel>
      <Select
        id={`search-${key}`}
        value={draft[key] || ''}
        onChange={(e) => set(key, e.target.value)}
      >
        <option value="">全て</option>
        {(options?.[key] || []).map((option) => (
          <option key={option.value} value={option.value}>
            {option.value}（{option.count.toLocaleString()}）
          </option>
        ))}
      </Select>
    </div>
  );

  const numberRangeField = (key: string, step: string) => (
    <div key={key}>
      <FieldLabel>{key}</FieldLabel>
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
    </div>
  );

  const dateRangeField = (key: string) => (
    <div key={key}>
      <FieldLabel>{key}</FieldLabel>
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
    </div>
  );

  return (
    <Panel onSubmit={submit}>
      <Grid>{BASIC_TEXT_KEYS.map(textField)}</Grid>

      {detailOpen && (
        <>
          <DetailSection>
            <SectionTitle>詳細条件</SectionTitle>
            <Grid>
              {SUGGEST_KEYS.map(suggestField)}
              {DETAIL_TEXT_KEYS.map(textField)}
              {SELECT_KEYS.map(selectField)}
            </Grid>
          </DetailSection>
          <DetailSection>
            <SectionTitle>範囲で絞り込む</SectionTitle>
            <Grid>
              {NUMBER_RANGE_KEYS.map(({ key, step }) => numberRangeField(key, step))}
              {DATE_RANGE_KEYS.map(dateRangeField)}
            </Grid>
          </DetailSection>
        </>
      )}

      <Toggle type="button" onClick={() => setDetailOpen(!detailOpen)}>
        {detailOpen ? '詳細条件を閉じる' : '詳細条件を開く'}
      </Toggle>

      <Actions>
        <Button type="button" onClick={clear}>
          クリア
        </Button>
        <PrimaryButton type="submit">検索</PrimaryButton>
      </Actions>
    </Panel>
  );
};
