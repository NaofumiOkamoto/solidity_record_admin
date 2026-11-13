import { Fragment, useCallback, useEffect, useRef, useState } from 'react';
import ReactLoading from 'react-loading';
import styled from 'styled-components';
import { Layout } from '../parts/Layout';
import {
  AddBar,
  CellInput,
  CellTextarea,
  Count,
  ErrorRow,
  ErrorText,
  Flash,
  formatDate,
  formatDateTime,
  Help,
  Loading,
  Muted,
  Row,
  RowActions,
  Scroll as BaseScroll,
  Stamp,
  Table,
  Td,
  Th,
  Tip,
} from '../parts/MasterTable';
import {
  EMPTY_TEMPLATE_FILTER,
  isFiltering,
  matchesTemplate,
  TemplateFilter,
  TemplateFilterValues,
} from '../parts/TemplateFilter';
import { Button, PrimaryButton } from '../parts/ui';
import { api } from '../lib/api';
import { DESCRIPTION_TARGETS, DescriptionTarget, DescriptionTemplate } from '../lib/descriptionTemplates';

// 説明文の定型文マスタ（docs/07-description-template.md）。作りはジャンル（06）と同じで、1行ずつ行内で編集する。
// 盤（record）とジャケット（cover）はモーダルも別なので、タブで分けて出す。

type FormValues = {
  category: string;
  jp: string;
  en: string;
  en_both: string;
  note: string;
  position: string;
};
type EditableKey = keyof FormValues;

const EMPTY: FormValues = { category: '', jp: '', en: '', en_both: '', note: '', position: '' };

// 列の定義。幅の考え方はジャンル一覧と同じ（基準幅の比率で広げ、min-width で下限を押さえる）
const COLUMNS: Array<{
  key: EditableKey | 'updated_at' | 'actions';
  label: string;
  width: number;
  align?: 'right';
  help?: string;
  tipAlign?: 'left' | 'right';
}> = [
  {
    key: 'position',
    label: '順番',
    width: 64,
    align: 'right',
    help: [
      '小さい順にモーダルに並びます。説明文に並べる順もこの順です。',
      '',
      '10, 20, 30 … と間をあけて振っておくと、間に入れるときに他を直さずに済みます。',
      '追加のときに空欄にすると末尾になります。',
    ].join('\n'),
  },
  {
    key: 'category',
    label: '分類',
    width: 140,
    help: 'モーダルでの見出しです。既存の値が入力候補に出ます。新しい分類も入力できます',
  },
  {
    key: 'jp',
    label: '日本語',
    width: 230,
    help: [
      'record_description_jp / cover_description_jp に入る文です。',
      '「。」で終わるようにしてください。「盤に歪み。プレイOK。」のように2文でも構いません。',
      '',
      'A面・B面・両面だけが違う文は、面のところを {面} と書くと1件で済みます。',
      'モーダルで A面・B面・両面を選べるようになります。',
      '例: {面}のラベルにダメージ。',
    ].join('\n'),
  },
  {
    key: 'en',
    label: '英語',
    width: 230,
    help: [
      'record_description_en / cover_description_en に入る文です。',
      '「.」で終わるようにしてください。',
      '',
      '日本語に {面} があるときは、A面・B面のときの英文を書き、面のところを {side} にします。',
      '{side} は A side / B side に置き換わります。',
      '例: Some damage on {side} label.',
      '',
      '同じ英文の定型文を2つチェックしたときは、英語には1回だけ入ります。',
    ].join('\n'),
  },
  {
    key: 'en_both',
    label: '英語（両面）',
    width: 200,
    tipAlign: 'right',
    help: [
      '日本語に {面} があるときだけ使います。両面を選んだときに入る英文です。',
      '空欄にすると、モーダルで「両面」を選べなくなります（「A面のプレイは〜」のように両面では使わない文のとき）。',
      '例: Some damage on both side labels.',
      '',
      '両面は「labels」「both sides」のように複数形になるため、{side} の置き換えではなく別に書きます。',
    ].join('\n'),
  },
  {
    key: 'note',
    label: 'メモ',
    width: 150,
    tipAlign: 'right',
    help: [
      '定型文を選ぶときの目安です。任意。',
      '',
      'モーダルで定型文の横に（ ）付きで小さく出ます。説明文には入りません。',
      '例: VG 以下の盤に使用',
    ].join('\n'),
  },
  { key: 'updated_at', label: '最終更新', width: 94, tipAlign: 'right', help: '最後に保存した日時' },
  { key: 'actions', label: '', width: 100 },
];

const EDITABLE_KEYS: EditableKey[] = ['position', 'category', 'jp', 'en', 'en_both', 'note'];

const TABLE_MIN_WIDTH = COLUMNS.reduce((sum, c) => sum + c.width, 0);
const widthPercent = (width: number) => `${((width / TABLE_MIN_WIDTH) * 100).toFixed(4)}%`;

const Tabs = styled.div`
  display: flex;
  gap: 4px;
  margin-bottom: 12px;
  border-bottom: solid 1px #ddd;
`;
const Tab = styled.button<{ $current: boolean }>`
  padding: 8px 16px;
  margin-bottom: -1px;
  border: solid 1px ${(p) => (p.$current ? '#ddd' : 'transparent')};
  border-bottom-color: ${(p) => (p.$current ? '#fff' : 'transparent')};
  border-radius: 4px 4px 0 0;
  background-color: ${(p) => (p.$current ? '#fff' : 'transparent')};
  color: ${(p) => (p.$current ? '#333' : '#3b5d8f')};
  font-size: 14px;
  font-weight: ${(p) => (p.$current ? 'bold' : 'normal')};
  cursor: pointer;
  &:disabled {
    cursor: not-allowed;
    color: #aaa;
  }
`;

// ジャンル一覧よりタブと絞り込みの段が多いぶん、表の高さの上限を下げる
const Scroll = styled(BaseScroll)`
  max-height: max(320px, calc(100vh - 320px));
`;
const TranslateButton = styled.button`
  margin-top: 4px;
  padding: 2px 8px;
  border: solid 1px #3b5d8f;
  border-radius: 3px;
  background-color: #fff;
  color: #3b5d8f;
  font-size: 11px;
  cursor: pointer;
  &:disabled {
    cursor: wait;
    color: #aaa;
    border-color: #ccc;
  }
`;
const TranslateNote = styled.span`
  display: block;
  margin-top: 2px;
  font-size: 11px;
  color: #2f6b26;
`;
const Filter = styled(TemplateFilter)`
  margin-bottom: 10px;
`;

type Editing = number | 'new' | null;

export const DescriptionTemplateList = () => {
  const [templates, setTemplates] = useState<DescriptionTemplate[]>([]);
  const [target, setTarget] = useState<DescriptionTarget>('record');
  const [filter, setFilter] = useState<TemplateFilterValues>(EMPTY_TEMPLATE_FILTER);
  const [editing, setEditing] = useState<Editing>(null);
  const scrollRef = useRef<HTMLDivElement>(null);
  const [draft, setDraft] = useState<FormValues>(EMPTY);
  const [rowErrors, setRowErrors] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [translating, setTranslating] = useState(false);
  // 英訳の結果。欄の中身が変わらないこともある（既存の定型文と同じ日本語なら同じ英文が返る）ので、押した結果を出す
  const [translateNote, setTranslateNote] = useState('');
  const [loadError, setLoadError] = useState('');
  const [flash, setFlash] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  const load = useCallback(async () => {
    try {
      const res = await api.get<{ description_templates: DescriptionTemplate[] }>('/api/description_templates');
      setTemplates(res.data.description_templates);
      setLoadError('');
    } catch (e) {
      console.log('e', e);
      setLoadError('定型文の取得に失敗しました。時間をおいて再度お試しください。');
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  useEffect(() => {
    if (flash?.type !== 'success') return;

    const timer = setTimeout(() => setFlash(null), 5000);
    return () => clearTimeout(timer);
  }, [flash]);

  const stopEditing = () => {
    setTranslateNote('');
    setEditing(null);
    setDraft(EMPTY);
    setRowErrors([]);
  };

  const startEdit = (template: DescriptionTemplate) => {
    setDraft({
      category: template.category,
      jp: template.jp,
      en: template.en,
      en_both: template.en_both || '',
      note: template.note || '',
      position: String(template.position),
    });
    setEditing(template.id);
    setRowErrors([]);
    setTranslateNote('');
    setFlash(null);
  };

  const startAdd = () => {
    setDraft(EMPTY);
    setEditing('new');
    setRowErrors([]);
    setTranslateNote('');
    setFlash(null);
  };

  // 追加の行は表の末尾に出るので、表の中を一番下までスクロールして見えるようにする
  useEffect(() => {
    if (editing !== 'new' || !scrollRef.current) return;
    scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
  }, [editing]);

  // API のバリデーションエラー（422）は日本語で返ってくるのでそのまま表示する
  const errorsOf = (e) => e?.response?.data?.errors || ['保存に失敗しました。入力内容を確認してください。'];

  const save = async () => {
    setSubmitting(true);
    setRowErrors([]);
    try {
      if (editing === 'new') {
        const res = await api.post<{ description_template: DescriptionTemplate }>('/api/description_templates', {
          description_template: { ...draft, target },
        });
        setFlash({ type: 'success', message: `「${res.data.description_template.jp}」を追加しました` });
      } else {
        const res = await api.patch<{ description_template: DescriptionTemplate }>(
          `/api/description_templates/${editing}`,
          { description_template: draft },
        );
        setFlash({ type: 'success', message: `「${res.data.description_template.jp}」を更新しました` });
      }
      stopEditing();
      await load();
    } catch (e) {
      console.log('e', e);
      setRowErrors(errorsOf(e));
    } finally {
      setSubmitting(false);
    }
  };

  const remove = async (template: DescriptionTemplate) => {
    if (
      !window.confirm(
        `「${template.jp}」を削除します。よろしいですか？\n（この定型文で書いた商品の説明文はそのまま残ります）`,
      )
    )
      return;

    setFlash(null);
    try {
      await api.delete(`/api/description_templates/${template.id}`);
      setFlash({ type: 'success', message: `「${template.jp}」を削除しました` });
      await load();
    } catch (e) {
      console.log('e', e);
      setFlash({ type: 'error', message: errorsOf(e).join(' / ') });
    }
  };

  const ofTarget = templates.filter((template) => template.target === target);
  const categories = Array.from(new Set(ofTarget.map((template) => template.category)));
  // 編集中の行は、絞り込みの条件から外れても隠さない（入力途中で消えないように）
  const shown = ofTarget.filter((template) => template.id === editing || matchesTemplate(template, filter));
  const filtered = isFiltering(filter);
  const set = (key: EditableKey, value: string) => setDraft({ ...draft, [key]: value });

  // 日本語から英語と英語（両面）を作って欄に入れる（API 経由で Gemini。保存はしない）。
  // 入力済みの英語を上書きするときは確認を出す
  const translate = async () => {
    if ((draft.en || draft.en_both) && !window.confirm('入力済みの英語を、英訳した文で置き換えます。よろしいですか？'))
      return;

    setTranslating(true);
    setRowErrors([]);
    setTranslateNote('');
    try {
      const res = await api.post<{ en: string; en_both: string }>('/api/description_templates/translate', {
        target,
        jp: draft.jp,
        // 編集中の定型文は例から外してもらう（入れると既存の英文がそのまま返る）
        id: editing === 'new' ? undefined : editing,
      });
      const unchanged = res.data.en === draft.en && res.data.en_both === draft.en_both;
      setDraft((current) => ({ ...current, en: res.data.en, en_both: res.data.en_both }));
      setTranslateNote(unchanged ? '入力済みの英文と同じ訳でした' : '英訳を入れました。確かめてから保存してください');
    } catch (e) {
      console.log('e', e);
      setRowErrors(e?.response?.data?.errors || ['英訳に失敗しました。英語は手で入力してください。']);
    } finally {
      setTranslating(false);
    }
  };

  const editCell = (key: EditableKey) => {
    if (key === 'jp') {
      return (
        <>
          <CellTextarea rows={2} value={draft.jp} onChange={(e) => set('jp', e.target.value)} />
          <TranslateButton
            type="button"
            onClick={translate}
            disabled={translating || submitting || draft.jp.trim() === ''}
            title="この日本語から英語と英語（両面）を作って、右の欄に入れます。保存前に確かめてください"
          >
            {translating ? '英訳中…' : '英訳を作る →'}
          </TranslateButton>
          {translateNote && <TranslateNote>{translateNote}</TranslateNote>}
        </>
      );
    }
    if (key === 'en' || key === 'en_both') {
      return <CellTextarea rows={2} value={draft[key]} onChange={(e) => set(key, e.target.value)} />;
    }
    return (
      <CellInput
        value={draft[key]}
        type={key === 'position' ? 'number' : undefined}
        placeholder={key === 'position' && editing === 'new' ? '末尾' : undefined}
        list={key === 'category' ? 'template-categories' : undefined}
        onChange={(e) => set(key, e.target.value)}
      />
    );
  };

  const viewCell = (template: DescriptionTemplate, key: EditableKey) => {
    const value = template[key];
    return value === null || value === '' ? <Muted>—</Muted> : value;
  };

  const actionCell = (template: DescriptionTemplate | null) => {
    const isEditingThis = template ? editing === template.id : editing === 'new';
    if (isEditingThis) {
      return (
        <RowActions>
          <Button type="button" onClick={stopEditing} disabled={submitting}>
            取消
          </Button>
          <PrimaryButton type="button" onClick={save} disabled={submitting || translating}>
            保存
          </PrimaryButton>
        </RowActions>
      );
    }
    if (!template) return null;

    return (
      <RowActions>
        <Button type="button" onClick={() => startEdit(template)} disabled={editing !== null}>
          編集
        </Button>
        <Button type="button" onClick={() => remove(template)} disabled={editing !== null}>
          削除
        </Button>
      </RowActions>
    );
  };

  const errorRow = () =>
    rowErrors.length > 0 && (
      <tr>
        <ErrorRow colSpan={COLUMNS.length}>{rowErrors.join(' / ')}</ErrorRow>
      </tr>
    );

  return (
    <Layout>
      <h2>説明文の定型文</h2>

      {flash && (
        <Flash $type={flash.type} role="status" aria-live="polite">
          {flash.message}
        </Flash>
      )}

      {loadError && <ErrorText>{loadError}</ErrorText>}

      {isLoading ? (
        <Loading>
          <ReactLoading type="spinningBubbles" color="#b2cbf3" height="80px" width="80px" />
        </Loading>
      ) : (
        !loadError && (
          <>
            <Tabs>
              {DESCRIPTION_TARGETS.map(({ value, label }) => (
                <Tab
                  key={value}
                  type="button"
                  $current={value === target}
                  // 編集中に切り替えると、編集中の行が見えなくなるため
                  disabled={editing !== null && value !== target}
                  onClick={() => {
                    setTarget(value);
                    // 分類は対象ごとに違うので、切り替えたら外す
                    setFilter({ ...filter, category: '' });
                  }}
                >
                  {label}（{templates.filter((template) => template.target === value).length}）
                </Tab>
              ))}
            </Tabs>
            <Filter values={filter} categories={categories} onChange={setFilter} />
            <Count>{filtered ? `${shown.length}件（全${ofTarget.length}件）` : `${shown.length}件`}</Count>
            <Scroll ref={scrollRef}>
              <Table $minWidth={TABLE_MIN_WIDTH}>
                <colgroup>
                  {COLUMNS.map((column) => (
                    <col key={column.key} style={{ width: widthPercent(column.width) }} />
                  ))}
                </colgroup>
                <thead>
                  <tr>
                    {COLUMNS.map((column) => (
                      <Th key={column.key} $align={column.align}>
                        {column.label}
                        {column.help && (
                          <Help tabIndex={0} role="note" aria-label={column.help}>
                            ?<Tip $align={column.tipAlign || 'left'}>{column.help}</Tip>
                          </Help>
                        )}
                      </Th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {shown.map((template) => {
                    const isEditingThis = editing === template.id;
                    return (
                      <Fragment key={template.id}>
                        <Row $editing={isEditingThis}>
                          {EDITABLE_KEYS.map((key) => (
                            <Td key={key} $align={key === 'position' ? 'right' : undefined}>
                              {isEditingThis ? editCell(key) : viewCell(template, key)}
                            </Td>
                          ))}
                          <Td title={formatDateTime(template.updated_at)}>
                            <Stamp>{formatDate(template.updated_at)}</Stamp>
                          </Td>
                          <Td>{actionCell(template)}</Td>
                        </Row>
                        {isEditingThis && errorRow()}
                      </Fragment>
                    );
                  })}

                  {editing === 'new' && (
                    <>
                      <Row $editing>
                        {EDITABLE_KEYS.map((key) => (
                          <Td key={key}>{editCell(key)}</Td>
                        ))}
                        <Td>
                          <Muted>—</Muted>
                        </Td>
                        <Td>{actionCell(null)}</Td>
                      </Row>
                      {errorRow()}
                    </>
                  )}
                </tbody>
              </Table>
            </Scroll>

            <datalist id="template-categories">
              {categories.map((category) => (
                <option key={category} value={category} />
              ))}
            </datalist>

            <AddBar>
              <Button type="button" onClick={startAdd} disabled={editing !== null}>
                ＋ 追加
              </Button>
            </AddBar>
          </>
        )
      )}
    </Layout>
  );
};
