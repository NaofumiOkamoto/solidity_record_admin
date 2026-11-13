import styled from 'styled-components';
import { Input, Select } from './ui';
import { DescriptionTemplate } from '../lib/descriptionTemplates';

// 説明文の定型文の絞り込み（「定型文」画面と、商品詳細の定型文モーダルで共用）。
// 全件を読み込んであるので、画面の中だけで絞る。

const Bar = styled.div`
  display: flex;
  align-items: center;
  gap: 10px;
`;
const KeywordInput = styled(Input)`
  width: 320px;
`;
const CategorySelect = styled(Select)`
  width: 200px;
`;
const ClearButton = styled.button`
  padding: 0;
  border: none;
  background: none;
  color: #3b5d8f;
  font-size: 13px;
  cursor: pointer;
  text-decoration: underline;
`;

export type TemplateFilterValues = { keyword: string; category: string };
export const EMPTY_TEMPLATE_FILTER: TemplateFilterValues = { keyword: '', category: '' };

export const isFiltering = ({ keyword, category }: TemplateFilterValues) => keyword.trim() !== '' || category !== '';

// キーワードは空白区切りで AND。日本語・英語・英語（両面）・分類・メモのどれかに含まれていればよい
export const matchesTemplate = (template: DescriptionTemplate, { keyword, category }: TemplateFilterValues) => {
  const words = keyword.trim().toLowerCase().split(/\s+/).filter(Boolean);
  return (
    (!category || template.category === category) &&
    words.every((word) =>
      [template.jp, template.en, template.en_both || '', template.category, template.note || ''].some((text) =>
        text.toLowerCase().includes(word),
      ),
    )
  );
};

type Props = {
  values: TemplateFilterValues;
  categories: string[];
  onChange: (values: TemplateFilterValues) => void;
  className?: string;
};

export const TemplateFilter = ({ values, categories, onChange, className }: Props) => (
  <Bar className={className}>
    <CategorySelect value={values.category} onChange={(e) => onChange({ ...values, category: e.target.value })}>
      <option value="">分類：すべて</option>
      {categories.map((category) => (
        <option key={category} value={category}>
          {category}
        </option>
      ))}
    </CategorySelect>
    <KeywordInput
      type="search"
      value={values.keyword}
      placeholder="キーワード（日本語・英語・分類・メモ）"
      onChange={(e) => onChange({ ...values, keyword: e.target.value })}
    />
    {isFiltering(values) && (
      <ClearButton type="button" onClick={() => onChange(EMPTY_TEMPLATE_FILTER)}>
        条件をクリア
      </ClearButton>
    )}
  </Bar>
);
