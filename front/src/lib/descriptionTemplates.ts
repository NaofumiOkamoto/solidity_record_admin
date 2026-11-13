// 説明文の定型文（docs/07-description-template.md）。
// 定型文そのものは DB のマスタ（/api/description_templates）にあり、「定型文」画面で追加・編集・削除する。
// ここには型と、説明文に定型文を当てはめる処理を置く。

export type DescriptionTarget = 'record' | 'cover';

export const DESCRIPTION_TARGETS: { value: DescriptionTarget; label: string }[] = [
  { value: 'record', label: '盤（record_description）' },
  { value: 'cover', label: 'ジャケット（cover_description）' },
];

// jp は「。」で終わる文を1つ以上、en は「.」で終わる文を1つ以上（API 側で検証している）。
// 説明文はこれらを並べてつないだものになる。
//
// A面・B面・両面だけが違う文は1件にまとめてある。jp に {面} があれば面を選べる定型文で、
// 英語は片面なら en の {side} を A side / B side に置き換え、両面なら en_both を使う
// （両面は「both side labels」のように複数形になり、置き換えでは作れないため）。
export type DescriptionTemplate = {
  id: number;
  target: DescriptionTarget;
  // モーダルでの見出し
  category: string;
  jp: string;
  en: string;
  // 両面用の英語。jp に {面} があるときだけ使う。空なら「両面」は選べない
  en_both: string | null;
  // どういうときに使うか。説明文には入らない
  note: string | null;
  // 並び順。モーダルでの表示順で、説明文に並べる順にもなる
  position: number;
  updated_at: string;
};

// ---- 説明文と定型文の突き合わせ ----
//
// 説明文を文に分け、定型文の文の並びがそのまま含まれていれば「その定型文が使われている」とみなす。
// 反映では、使われていた定型文の文を取り除いてから、チェックした定型文を定型文の並び順で先頭に置き、
// 手で書いた文（どの定型文にも当たらない文）はその後ろに元の順で残す。

export const splitJp = (text: string) =>
  text
    .split(/(?<=。)/)
    .map((sentence) => sentence.trim())
    .filter(Boolean);

export const splitEn = (text: string) =>
  text
    .split(/(?<=\.)\s+/)
    .map((sentence) => sentence.trim())
    .filter(Boolean);

const indexOfSequence = (sentences: string[], sequence: string[]) =>
  sentences.findIndex((_, start) => sequence.every((sentence, offset) => sentences[start + offset] === sentence));

const removeSequence = (sentences: string[], sequence: string[]) => {
  const start = indexOfSequence(sentences, sequence);
  if (start === -1) return sentences;
  return [...sentences.slice(0, start), ...sentences.slice(start + sequence.length)];
};

export const SIDE_JP = '{面}';
export const SIDE_EN = '{side}';

export type Side = 'A' | 'B' | 'both';
export const SIDES: { value: Side; jp: string; en: string }[] = [
  { value: 'A', jp: 'A面', en: 'A side' },
  { value: 'B', jp: 'B面', en: 'B side' },
  { value: 'both', jp: '両面', en: '' },
];

export const hasSide = (template: DescriptionTemplate) => template.jp.includes(SIDE_JP);

// 定型文を、実際に説明文に入る文に展開したもの。面を選べる定型文は A面・B面・両面の3つになる
// （英語（両面）が空なら A面・B面の2つ）。
// モーダルのチェックはこの key で持つ
export type TemplateVariant = { key: string; template: DescriptionTemplate; side: Side | null; jp: string; en: string };

const replaceAll = (text: string, from: string, to: string) => text.split(from).join(to);

export const variantsOf = (template: DescriptionTemplate): TemplateVariant[] => {
  if (!hasSide(template)) {
    return [{ key: String(template.id), template, side: null, jp: template.jp, en: template.en }];
  }
  return SIDES.filter((side) => side.value !== 'both' || template.en_both).map((side) => ({
    key: `${template.id}:${side.value}`,
    template,
    side: side.value,
    jp: replaceAll(template.jp, SIDE_JP, side.jp),
    en: side.value === 'both' ? template.en_both || '' : replaceAll(template.en, SIDE_EN, side.en),
  }));
};

// 説明文（日本語）に含まれている定型文（の面）
export const usedVariantKeys = (templates: DescriptionTemplate[], jp: string) => {
  const sentences = splitJp(jp);
  return templates
    .flatMap(variantsOf)
    .filter((variant) => indexOfSequence(sentences, splitJp(variant.jp)) !== -1)
    .map((variant) => variant.key);
};

export const applyTemplates = (
  templates: DescriptionTemplate[],
  current: { jp: string; en: string },
  checkedKeys: string[],
) => {
  const variants = templates.flatMap(variantsOf);
  // 取り除くのは、今の日本語に含まれていた定型文の文だけ。
  // 英語だけに定型文と同じ文があっても、手で書いた文かもしれないので残す
  const usedKeys = usedVariantKeys(templates, current.jp);
  const used = variants.filter((variant) => usedKeys.includes(variant.key));
  let restJp = splitJp(current.jp);
  let restEn = splitEn(current.en);
  used.forEach((variant) => {
    restJp = removeSequence(restJp, splitJp(variant.jp));
    restEn = removeSequence(restEn, splitEn(variant.en));
  });

  // チェックを変えていなければ元の文のまま返す（反映を押しただけで文の順番が変わらないように）
  const unchanged = used.length === checkedKeys.length && used.every((variant) => checkedKeys.includes(variant.key));
  if (unchanged) return { ...current, manualJp: restJp };

  // 並びは定型文の順。同じ定型文の面は A面 → B面 → 両面
  const checked = variants.filter((variant) => checkedKeys.includes(variant.key));
  const jp = [...checked.flatMap((variant) => splitJp(variant.jp)), ...restJp].join('');
  // 「Plays good.」のように複数の定型文で同じ英文があるので、重ねて出さない
  const en = Array.from(new Set([...checked.flatMap((variant) => splitEn(variant.en)), ...restEn])).join(' ');
  return { jp, en, manualJp: restJp };
};
