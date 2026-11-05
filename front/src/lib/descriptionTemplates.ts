// 説明文の定型文（クライアント依頼・2026-11）。
//
// **仮のデータ。** 操作のイメージを見てもらうために、依頼ドキュメントの例と実データでよく使われている文から
// 適当に選んで置いている。定型文を DB で管理して石井さん側で追加・編集できるようにするかは確認中
// （docs/03 の「説明文の定型文」）。決まったら API から取るように置き換える。
//
// jp は「。」で終わる文を1つ以上、en は「.」で終わる文を1つ以上。説明文はこれらを並べてつないだものになる。

export type DescriptionTarget = 'record' | 'cover';

export type DescriptionTemplate = {
  id: string;
  target: DescriptionTarget;
  category: string;
  jp: string;
  en: string;
  // どういうときに使うか。説明文には入らない
  note?: string;
};

type Row = [category: string, jp: string, en: string, note?: string];

const RECORD: Row[] = [
  ['ラベルの状態', '両面のラベルに若干のダメージ。', 'Slight damage on both side labels.'],
  ['ラベルの状態', '両面のラベルにダメージ。', 'Some damage on both side labels.'],
  ['ラベルの状態', 'A面のラベルに若干のダメージ。', 'Slight damage on A side label.'],
  ['ラベルの状態', 'A面のラベルにダメージ。', 'Some damage on A side label.'],
  ['ラベルの状態', 'B面のラベルに若干のダメージ。', 'Slight damage on B side label.'],
  ['ラベルの状態', 'B面のラベルにダメージ。', 'Some damage on B side label.'],
  ['ラベルの状態', 'A面のラベルに書き込み。', 'Writing on A side label.'],
  ['ラベルの状態', 'A面のラベルにステッカー。', 'Sticker on A side label.'],
  ['盤の状態', '盤に若干の歪み。プレイOK。', "Slight edge warp. But doesn't affect playing."],
  ['盤の状態', '盤に歪み。プレイOK。', "Edge warp. But doesn't affect playing."],
  ['盤の状態', 'エッジに若干の欠け。', 'Slight chip on the edge.'],
  ['盤の状態', 'エッジに欠け。', 'Chip on the edge.'],
  ['音質', '多少の傷はあるが、おおむね良好。', 'But good shape.', 'VG+ 以上の盤に使用'],
  ['音質', '傷はあるが、プレイはおおむね良好。', 'Plays good.', 'VG〜VG+ の盤に使用'],
  ['音質', '傷は多いが、プレイはまずまず。', 'Plays good.', 'VG 以下の盤に使用'],
  ['その他', 'プロモ盤。', 'Promo copy.'],
  ['その他', 'カンパニースリーブ付き。', 'With company sleeve.'],
  ['その他', 'ジャケットなし。', 'No cover.'],
];

const COVER: Row[] = [
  ['付属品', '帯とインサート付き。', 'With OBI and insert.'],
  ['付属品', '帯付き。', 'With OBI.'],
  ['付属品', '帯なし。', 'No OBI.'],
  ['付属品', 'インサート付き。', 'With insert.'],
  ['付属品', 'インサートなし。', 'No insert.'],
  ['ジャケットの状態', '見開きジャケット。', 'Gatefold cover.'],
  ['ジャケットの状態', 'ジャケットに若干のシミ。', 'Slight brown stains on cover.'],
  ['ジャケットの状態', 'ジャケットにシミ。', 'Some brown stains on cover.'],
  ['帯・インサートの状態', '帯に若干のダメージ。', 'Slight damage on OBI.'],
  ['帯・インサートの状態', 'インサートにシミ。', 'Some brown stains on insert.'],
];

const build = (target: DescriptionTarget, rows: Row[]): DescriptionTemplate[] =>
  rows.map(([category, jp, en, note], index) => ({ id: `${target}-${index}`, target, category, jp, en, note }));

export const DESCRIPTION_TEMPLATES: DescriptionTemplate[] = [...build('record', RECORD), ...build('cover', COVER)];

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

// 説明文（日本語）に含まれている定型文
export const usedTemplateIds = (templates: DescriptionTemplate[], jp: string) => {
  const sentences = splitJp(jp);
  return templates.filter((template) => indexOfSequence(sentences, splitJp(template.jp)) !== -1).map((t) => t.id);
};

export const applyTemplates = (
  templates: DescriptionTemplate[],
  current: { jp: string; en: string },
  checkedIds: string[],
) => {
  // 取り除くのは、今の日本語に含まれていた定型文の文だけ。
  // 英語だけに定型文と同じ文があっても、手で書いた文かもしれないので残す
  const used = templates.filter((template) => usedTemplateIds([template], current.jp).length > 0);
  let restJp = splitJp(current.jp);
  let restEn = splitEn(current.en);
  used.forEach((template) => {
    restJp = removeSequence(restJp, splitJp(template.jp));
    restEn = removeSequence(restEn, splitEn(template.en));
  });

  // チェックを変えていなければ元の文のまま返す（反映を押しただけで文の順番が変わらないように）
  const unchanged = used.length === checkedIds.length && used.every((template) => checkedIds.includes(template.id));
  if (unchanged) return { ...current, manualJp: restJp };

  const checked = templates.filter((template) => checkedIds.includes(template.id));
  const jp = [...checked.flatMap((template) => splitJp(template.jp)), ...restJp].join('');
  // 「Plays good.」のように複数の定型文で同じ英文があるので、重ねて出さない
  const en = Array.from(new Set([...checked.flatMap((template) => splitEn(template.en)), ...restEn])).join(' ');
  return { jp, en, manualJp: restJp };
};
