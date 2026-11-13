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
  Scroll,
  Stamp,
  Table,
  Td,
  Th,
  Tip,
} from '../parts/MasterTable';
import { Button, PrimaryButton } from '../parts/ui';
import { api } from '../lib/api';
import {
  Genre,
  GenreForm as GenreFormValues,
  YAHOO_AUCTION_BY_ARTIST_INITIAL,
} from '../types/product';

const EMPTY: GenreFormValues = {
  main: '',
  sub: '',
  yahoo_path: '',
  mercari_keywords: '',
  ebay_category: '',
  yahoo_auction_category: '',
  tags: '',
};

// 編集対象の列。表示のみの列（id / 使用数 / 最終更新）とは分けて扱う
type EditableKey = keyof GenreFormValues;

// 列の定義。幅は box-sizing: border-box なので padding 込み。
// 合計 1,180px で、13.3インチ（1440px）に横スクロールなしで収まる。
// help は見出しの ? に出す説明。tipAlign は右端の列でツールチップが
// 横スクロール領域からはみ出して切れるのを避けるため。
const COLUMNS: Array<{
  key: EditableKey | 'id' | 'products_count' | 'updated_at' | 'actions';
  label: string;
  width: number;
  align?: 'right';
  help?: string;
  tipAlign?: 'left' | 'right';
}> = [
  { key: 'id', label: 'id', width: 44, align: 'right', help: '自動で採番されます。商品データから参照されるため変更できません' },
  { key: 'main', label: 'main', width: 124, help: '大分類。既存の値が入力候補に出ます。新しい分類も入力できます' },
  { key: 'sub', label: 'sub', width: 132, help: '小分類' },
  {
    key: 'yahoo_path',
    label: 'yahoo_path',
    width: 164,
    help: [
      'Yahoo 用 CSV の path 列（出品カテゴリ）に入る値です。',
      '',
      '「親:子」の形式で、複数のカテゴリに出品する場合は改行で並べます。',
      '  ジャズ',
      '  ジャズ:ビッグバンド',
      'と入力すると、LP:ジャズ と LP:ジャズ:ビッグバンド の2つが出力されます。',
      '',
      '先頭の LP: や 7インチ: は商品のフォーマットから自動で付くので、入力は不要です。',
    ].join('\n'),
  },
  {
    key: 'mercari_keywords',
    label: 'mercari_keywords',
    width: 140,
    help: [
      'メルカリ・ヤフオクの商品名の末尾に付ける語です。',
      '例: JAZZ ジャズ',
      '',
      '「アーティスト名 タイトル レーベル 国 番号 SKU ＋ この語 ＋ レコード LP」',
      'という形で商品名が組み立てられます。',
    ].join('\n'),
  },
  {
    key: 'ebay_category',
    label: 'ebay_category',
    width: 100,
    help: 'eBay のカテゴリ。空欄にすると eBay のカテゴリ列は出力されません',
  },
  {
    key: 'yahoo_auction_category',
    label: 'yahoo_auction_cat.',
    width: 156,
    tipAlign: 'right',
    help: [
      'ヤフオクの出品カテゴリID。例: 2084007027',
      '',
      '「頭文字」にチェックを入れると、アーティスト名の1文字目でカテゴリを選びます。',
      'ヤフオクの洋楽ロック/ポップは A〜Z と数字で27通りに分かれるため、',
      'ジャンル1つに対してカテゴリIDが1つに決まりません。',
      '',
      '例: Rolling Stones → R のカテゴリ / 10cc → 数字のカテゴリ',
      '注意: The Beatles は The も1文字目として数えるため T になります。',
    ].join('\n'),
  },
  { key: 'tags', label: 'tags', width: 96, tipAlign: 'right', help: 'Shopify のタグ。任意' },
  {
    key: 'products_count',
    label: '使用数',
    width: 52,
    align: 'right',
    tipAlign: 'right',
    help: 'このジャンルを使っている商品の件数。1件以上あると削除できません',
  },
  { key: 'updated_at', label: '最終更新', width: 94, tipAlign: 'right', help: '最後に保存した日時' },
  { key: 'actions', label: '', width: 100 },
];

// 13.3インチ（1440px）に収まる幅を基準にしつつ、広い画面では幅いっぱいに広げる。
// 各列は基準幅の比率（%）で指定し、min-width で下限を押さえる。
const TABLE_MIN_WIDTH = COLUMNS.reduce((sum, c) => sum + c.width, 0);
const widthPercent = (width: number) => `${((width / TABLE_MIN_WIDTH) * 100).toFixed(4)}%`;

const Toggle = styled.label`
  display: flex;
  align-items: center;
  gap: 3px;
  margin-top: 3px;
  font-size: 10px;
  color: #555;
  white-space: nowrap;
  cursor: pointer;
`;
const Auto = styled.span`
  color: #3b5d8f;
  font-size: 11px;
`;

type Editing = number | 'new' | null;

export const GenreList = () => {
  const [genres, setGenres] = useState<Genre[]>([]);
  const [editing, setEditing] = useState<Editing>(null);
  const scrollRef = useRef<HTMLDivElement>(null);
  const [draft, setDraft] = useState<GenreFormValues>(EMPTY);
  const [rowErrors, setRowErrors] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [loadError, setLoadError] = useState('');
  const [flash, setFlash] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  const load = useCallback(async () => {
    try {
      const res = await api.get<{ genres: Genre[] }>('/api/genres');
      setGenres(res.data.genres);
      setLoadError('');
    } catch (e) {
      console.log('e', e);
      setLoadError('ジャンルの取得に失敗しました。時間をおいて再度お試しください。');
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
    setEditing(null);
    setDraft(EMPTY);
    setRowErrors([]);
  };

  const startEdit = (genre: Genre) => {
    setDraft({
      main: genre.main,
      sub: genre.sub,
      yahoo_path: genre.yahoo_path,
      mercari_keywords: genre.mercari_keywords,
      ebay_category: genre.ebay_category || '',
      tags: genre.tags || '',
      yahoo_auction_category: genre.yahoo_auction_category || '',
    });
    setEditing(genre.id);
    setRowErrors([]);
    setFlash(null);
  };

  const startAdd = () => {
    setDraft(EMPTY);
    setEditing('new');
    setRowErrors([]);
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
        const res = await api.post<{ genre: Genre }>('/api/genres', { genre: draft });
        setFlash({
          type: 'success',
          message: `「${res.data.genre.sub}」を追加しました（id: ${res.data.genre.id}）`,
        });
      } else {
        const res = await api.patch<{ genre: Genre }>(`/api/genres/${editing}`, { genre: draft });
        setFlash({
          type: 'success',
          message: `「${res.data.genre.sub}」を更新しました（id: ${editing}）`,
        });
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

  const remove = async (genre: Genre) => {
    if (!window.confirm(`id ${genre.id}「${genre.sub}」を削除します。よろしいですか？`)) return;

    setFlash(null);
    try {
      await api.delete(`/api/genres/${genre.id}`);
      setFlash({ type: 'success', message: `「${genre.sub}」を削除しました（id: ${genre.id}）` });
      await load();
    } catch (e) {
      console.log('e', e);
      // 使用中のジャンルはサーバー側で弾かれる
      setFlash({ type: 'error', message: errorsOf(e).join(' / ') });
    }
  };

  const mains = Array.from(new Set(genres.map((genre) => genre.main))).sort();
  const ebayCategories = Array.from(
    new Set(genres.map((genre) => genre.ebay_category).filter(Boolean) as string[]),
  ).sort();
  const byArtistInitial = draft.yahoo_auction_category === YAHOO_AUCTION_BY_ARTIST_INITIAL;
  const set = (key: EditableKey, value: string) => setDraft({ ...draft, [key]: value });

  const editCell = (key: EditableKey) => {
    if (key === 'yahoo_path') {
      return (
        <CellTextarea
          rows={2}
          value={draft.yahoo_path}
          onChange={(e) => set('yahoo_path', e.target.value)}
        />
      );
    }
    if (key === 'yahoo_auction_category') {
      return (
        <>
          <CellInput
            value={byArtistInitial ? '' : draft.yahoo_auction_category}
            disabled={byArtistInitial}
            onChange={(e) => set('yahoo_auction_category', e.target.value)}
          />
          <Toggle>
            <input
              type="checkbox"
              checked={byArtistInitial}
              onChange={(e) =>
                set('yahoo_auction_category', e.target.checked ? YAHOO_AUCTION_BY_ARTIST_INITIAL : '')
              }
            />
            頭文字で自動
          </Toggle>
        </>
      );
    }
    return (
      <CellInput
        value={draft[key]}
        list={key === 'main' ? 'genre-mains' : key === 'ebay_category' ? 'genre-ebay' : undefined}
        onChange={(e) => set(key, e.target.value)}
      />
    );
  };

  const viewCell = (genre: Genre, key: EditableKey) => {
    if (key === 'yahoo_auction_category') {
      if (genre.yahoo_auction_category === YAHOO_AUCTION_BY_ARTIST_INITIAL) {
        return <Auto>頭文字で自動</Auto>;
      }
      return genre.yahoo_auction_category || <Muted>—</Muted>;
    }
    return genre[key] || <Muted>—</Muted>;
  };

  const actionCell = (genre: Genre | null) => {
    const isEditingThis = genre ? editing === genre.id : editing === 'new';
    if (isEditingThis) {
      return (
        <RowActions>
          <Button type="button" onClick={stopEditing} disabled={submitting}>
            取消
          </Button>
          <PrimaryButton type="button" onClick={save} disabled={submitting}>
            保存
          </PrimaryButton>
        </RowActions>
      );
    }
    if (!genre) return null;

    return (
      <RowActions>
        <Button type="button" onClick={() => startEdit(genre)} disabled={editing !== null}>
          編集
        </Button>
        <Button
          type="button"
          onClick={() => remove(genre)}
          disabled={editing !== null || genre.products_count > 0}
          title={
            genre.products_count > 0
              ? `商品${genre.products_count}件で使われているため削除できません`
              : undefined
          }
        >
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
      <h2>ジャンル</h2>

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
            <Count>{genres.length}件</Count>
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
                            ?
                            <Tip $align={column.tipAlign || 'left'}>{column.help}</Tip>
                          </Help>
                        )}
                      </Th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {genres.map((genre) => {
                    const isEditingThis = editing === genre.id;
                    return (
                      <Fragment key={genre.id}>
                        <Row $editing={isEditingThis}>
                          <Td $align="right">{genre.id}</Td>
                          {(
                            [
                              'main',
                              'sub',
                              'yahoo_path',
                              'mercari_keywords',
                              'ebay_category',
                              'yahoo_auction_category',
                              'tags',
                            ] as EditableKey[]
                          ).map((key) => (
                            <Td key={key}>{isEditingThis ? editCell(key) : viewCell(genre, key)}</Td>
                          ))}
                          <Td $align="right">
                            {genre.products_count > 0 ? (
                              genre.products_count.toLocaleString()
                            ) : (
                              <Muted>0</Muted>
                            )}
                          </Td>
                          <Td title={formatDateTime(genre.updated_at)}>
                            <Stamp>{formatDate(genre.updated_at)}</Stamp>
                          </Td>
                          <Td>{actionCell(genre)}</Td>
                        </Row>
                        {isEditingThis && errorRow()}
                      </Fragment>
                    );
                  })}

                  {editing === 'new' && (
                    <>
                      <Row $editing>
                        <Td $align="right">
                          <Muted>—</Muted>
                        </Td>
                        {(
                          [
                            'main',
                            'sub',
                            'yahoo_path',
                            'mercari_keywords',
                            'ebay_category',
                            'yahoo_auction_category',
                            'tags',
                          ] as EditableKey[]
                        ).map((key) => (
                          <Td key={key}>{editCell(key)}</Td>
                        ))}
                        <Td $align="right">
                          <Muted>0</Muted>
                        </Td>
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

            <datalist id="genre-mains">
              {mains.map((main) => (
                <option key={main} value={main} />
              ))}
            </datalist>
            <datalist id="genre-ebay">
              {ebayCategories.map((c) => (
                <option key={c} value={c} />
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
