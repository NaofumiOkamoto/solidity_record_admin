import { useEffect, useState } from 'react';
import { Link, useLocation, useParams } from 'react-router-dom';
import ReactLoading from 'react-loading';
import styled from 'styled-components';
import { Layout } from '../parts/Layout';
import { SameReleaseList } from '../parts/SameReleaseList';
import { Button, FieldLabel, Input } from '../parts/ui';
import { api } from '../lib/api';
import { formatArtist, FromListState } from '../lib/format';
import { GenreOption, ProductDetail, ProductDetailResponse, SameReleaseItem } from '../types/product';

// 商品の詳細兼編集画面（docs/03-product-detail.md）。詳細と編集を別画面にせず、ここ1つで扱う。
//
// **今は保存できないので、入力欄はすべて読み取り専用。** CSV 出力のたびにスプレッドシートの値で
// products が上書きされるため、DB だけ更新しても消える。保存先（シートへの書き戻し等）が
// 決まったら、EDITABLE を外して保存ボタンを付ける。
//
// 項目の並びは docs/90-field-reference.md のセクション1〜3（商品登録モックの左・中・右列）。
// ただし左列は「Discogs 読込で埋まる項目」とそれ以外に分け、読込ボタンを埋まる項目の真上に置く。
// 値は DB のまま出す（グレードの "VG_VG+" など）。スプレッドシートで入力するのと同じ形にそろえるため。
const EDITABLE = false;

type Kind = 'text' | 'textarea' | 'link';
type Field = { key: keyof ProductDetail; kind?: Kind };

type Section = { title: string; note?: string; discogs?: boolean; fields: Field[] };

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
        { key: 'discogs_release_id' },
        { key: 'artist' },
        { key: 'title' },
        { key: 'label' },
        { key: 'country' },
        { key: 'number' },
        { key: 'release_year' },
        { key: 'format' },
      ],
    },
    {
      title: '基本情報',
      fields: [{ key: 'SKU' }, { key: 'genre' }, { key: 'item_condition' }],
    },
  ],
  [
    {
      title: 'コンディション・メディア',
      fields: [
        { key: 'record_grading' },
        { key: 'cover_grading' },
        { key: 'record_description_jp', kind: 'textarea' },
        { key: 'record_description_en', kind: 'textarea' },
        { key: 'cover_description_jp', kind: 'textarea' },
        { key: 'cover_description_en', kind: 'textarea' },
        { key: 'mp3_A', kind: 'link' },
        { key: 'mp3_B', kind: 'link' },
        { key: 'weight' },
        { key: 'img_count' },
      ],
    },
  ],
  [
    {
      title: '価格・在庫・ステータス',
      fields: [
        { key: 'price_jpy' },
        { key: 'price_usd' },
        { key: 'cost_price' },
        { key: 'quantity' },
        { key: 'registration_date' },
        { key: 'sold_date' },
        { key: 'sold_site' },
        { key: 'sales_status' },
      ],
    },
  ],
];

// 編集できるようになってもフォームには載せない項目。値があるときだけ下に出す。
// recoding_date / track_list / personnel は eBay の商品説明にだけ出る（99 B-1 で登録フォーム不要と確定）。
// discogs_listing_id は Discogs API から書き戻す列で、人が触ってはいけない（90 参照）
const EBAY_FIELDS: Field[] = [
  { key: 'recoding_date' },
  { key: 'track_list', kind: 'textarea' },
  { key: 'personnel', kind: 'textarea' },
  { key: 'discogs_listing_id' },
];

const isBlank = (value: unknown) => value == null || value === '';

// "2_10" → "Funk、60's Funk"。マスタに無い id も黙って捨てず、あることが分かるように出す。
// 編集できるようにするときは、ここをジャンルの複数選択に置き換える
const genreLabel = (value: string | null, genres: GenreOption[]) => {
  if (!value) return '';
  const byId = new Map(genres.map((genre) => [String(genre.id), genre]));
  return value
    .split('_')
    .filter((id) => /^\d+$/.test(id))
    .map((id) => byId.get(id)?.sub || `id ${id}（マスタに無し）`)
    .join('、');
};

const BackLink = styled(Link)`
  display: inline-block;
  margin-bottom: 16px;
  font-size: 14px;
  color: #3b5d8f;
  text-decoration: none;
  &:hover {
    text-decoration: underline;
  }
`;
const Heading = styled.div`
  margin-bottom: 16px;
`;
const SkuLine = styled.div`
  display: flex;
  align-items: center;
  gap: 12px;
`;
const Sku = styled.h2`
  margin: 0;
  font-size: 24px;
`;
const Badge = styled.span<{ $inStock: boolean }>`
  padding: 2px 10px;
  border-radius: 10px;
  font-size: 12px;
  font-weight: bold;
  color: ${(p) => (p.$inStock ? '#1e6b3a' : '#777')};
  background-color: ${(p) => (p.$inStock ? '#e3f4e8' : '#eee')};
`;
const Name = styled.p`
  margin: 6px 0 0;
  font-size: 16px;
  color: #333;
`;
const Notice = styled.p`
  margin: 0 0 16px;
  padding: 10px 14px;
  border-left: solid 4px #e0b44c;
  background-color: #fdf7e7;
  font-size: 13px;
  color: #6b5416;
`;
// 検索フォーム（02）と同じ区切りで 3 → 2 → 1 列に折り返す
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
const Panel = styled.section`
  background-color: #fff;
  border: solid 1px #ddd;
  border-radius: 4px;
  padding: 12px 16px;
`;
// Discogs で埋まる項目のまとまり。他のパネルと区別できるよう枠と見出しの色を変える
const DiscogsPanel = styled(Panel)`
  border-color: #b2cbf3;
  background-color: #f6f9fe;
`;
const PanelNote = styled.p`
  margin: -6px 0 12px;
  font-size: 12px;
  color: #777;
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
const Wide = styled(Panel)`
  margin-top: 16px;
`;
const PanelTitle = styled.h3`
  margin: 0 0 12px;
  font-size: 14px;
  color: #555;
`;
const Fields = styled.div`
  display: flex;
  flex-direction: column;
  gap: 10px;
`;
const LinkRow = styled.div`
  display: flex;
  align-items: center;
  gap: 8px;
`;
const OpenLink = styled.a`
  flex-shrink: 0;
  font-size: 13px;
  color: #3b5d8f;
`;
// 読み取り専用でも値は選択してコピーできるよう、disabled ではなく readOnly にする。
// 入力できそうに見えないよう背景だけ落とす
const ReadOnlyInput = styled(Input)`
  &:read-only {
    background-color: #f7f7f7;
    color: #222;
  }
`;
const ReadOnlyTextarea = styled.textarea`
  width: 100%;
  box-sizing: border-box;
  padding: 6px 8px;
  border: solid 1px #b3b3b3;
  border-radius: 2px;
  font-size: 14px;
  font-family: inherit;
  resize: vertical;
  &:read-only {
    background-color: #f7f7f7;
    color: #222;
  }
`;
const Loading = styled.div`
  display: flex;
  justify-content: center;
  padding: 60px;
`;
const Message = styled.p<{ $error?: boolean }>`
  padding: 40px;
  text-align: center;
  color: ${(p) => (p.$error ? '#c0392b' : '#555')};
`;

type FieldInputProps = { field: Field; product: ProductDetail; genres: GenreOption[] };

const FieldInput = ({ field, product, genres }: FieldInputProps) => {
  const id = `product-${field.key}`;
  const raw = product[field.key];
  const value = field.key === 'genre' ? genreLabel(product.genre, genres) : isBlank(raw) ? '' : String(raw);

  let control;
  if (field.kind === 'textarea') {
    control = <ReadOnlyTextarea id={id} value={value} rows={3} readOnly={!EDITABLE} />;
  } else if (field.kind === 'link') {
    control = (
      <LinkRow>
        <ReadOnlyInput id={id} value={value} readOnly={!EDITABLE} />
        {value && (
          <OpenLink href={value} target="_blank" rel="noreferrer">
            開く
          </OpenLink>
        )}
      </LinkRow>
    );
  } else {
    control = <ReadOnlyInput id={id} value={value} readOnly={!EDITABLE} />;
  }

  return (
    <div>
      <FieldLabel htmlFor={id}>{field.key}</FieldLabel>
      {control}
    </div>
  );
};

export const ProductForm = () => {
  const { sku = '' } = useParams();
  const location = useLocation();
  // 一覧から来たときは、検索条件ごと一覧に戻す。URL 直打ちなどで無ければ一覧の初期表示へ
  const from = (location.state as FromListState)?.from;
  const backTo = from || '/products';

  const [product, setProduct] = useState<ProductDetail | null>(null);
  const [genres, setGenres] = useState<GenreOption[]>([]);
  const [sameRelease, setSameRelease] = useState<SameReleaseItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [notFound, setNotFound] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    let aborted = false;
    setIsLoading(true);
    setNotFound(false);
    setError('');
    api
      .get<ProductDetailResponse>(`/api/products/${encodeURIComponent(sku)}`)
      .then((res) => {
        if (aborted) return;
        setProduct(res.data.product);
        setGenres(res.data.genres);
        setSameRelease(res.data.same_release);
      })
      .catch((e) => {
        if (aborted) return;
        setProduct(null);
        // 一覧へ自動で飛ばさない。打ち間違いか商品が消えたのかを利用者が判断できるよう、ここで伝える
        if (e.response?.status === 404) {
          setNotFound(true);
        } else {
          console.log('e', e);
          setError('エラーが発生しました。岡本まで連絡してください');
        }
      })
      .finally(() => {
        if (!aborted) setIsLoading(false);
      });
    // 同じ release の商品へ移ったときに、前の商品のスクロール位置のまま表示されないようにする
    window.scrollTo({ top: 0 });
    return () => {
      aborted = true;
    };
  }, [sku]);

  const ebayFields = product ? EBAY_FIELDS.filter((field) => !isBlank(product[field.key])) : [];
  const hasReleaseId = product && product.discogs_release_id != null && product.discogs_release_id !== 0;

  return (
    <Layout>
      <BackLink to={backTo}>← 一覧に戻る</BackLink>

      {isLoading && (
        <Loading>
          <ReactLoading type="spinningBubbles" color="#b2cbf3" height="80px" width="80px" />
        </Loading>
      )}

      {!isLoading && notFound && <Message>SKU {sku} の商品は見つかりません</Message>}
      {!isLoading && error && <Message $error>{error}</Message>}

      {!isLoading && product && (
        <>
          <Heading>
            <SkuLine>
              <Sku>SKU {product.SKU}</Sku>
              {product.quantity != null && (
                <Badge $inStock={product.quantity >= 1}>{product.quantity >= 1 ? '在庫あり' : '在庫なし'}</Badge>
              )}
            </SkuLine>
            <Name>
              {[formatArtist(product.artist), product.title].filter((value) => !isBlank(value)).join(' - ')}
            </Name>
          </Heading>

          {!EDITABLE && (
            <Notice>現在は閲覧のみです。商品の修正はこれまでどおりスプレッドシートで行ってください。</Notice>
          )}

          <Columns>
            {COLUMNS.map((sections) => (
              <Column key={sections[0].title}>
                {sections.map((section) => {
                  const SectionPanel = section.discogs ? DiscogsPanel : Panel;
                  return (
                    <SectionPanel key={section.title}>
                      <PanelTitle>{section.title}</PanelTitle>
                      {section.note && <PanelNote>{section.note}</PanelNote>}
                      <Fields>
                        {section.fields.map((field) =>
                          field.key === 'discogs_release_id' ? (
                            <ReleaseIdRow key={field.key}>
                              <FieldInput field={field} product={product} genres={genres} />
                              {/* GET /api/discogs/releases/:id ができるまで押せない（docs/03 の「Discogs 読込」） */}
                              <LoadButton type="button" disabled title="準備中">
                                読込
                              </LoadButton>
                            </ReleaseIdRow>
                          ) : (
                            <FieldInput key={field.key} field={field} product={product} genres={genres} />
                          ),
                        )}
                      </Fields>
                    </SectionPanel>
                  );
                })}
              </Column>
            ))}
          </Columns>

          {ebayFields.length > 0 && (
            <Wide>
              <PanelTitle>eBay 用の追加情報（この画面では編集しない）</PanelTitle>
              <Fields>
                {ebayFields.map((field) => (
                  <FieldInput key={field.key} field={field} product={product} genres={genres} />
                ))}
              </Fields>
            </Wide>
          )}

          {hasReleaseId && (
            <Wide>
              <PanelTitle>同じ discogs_release_id の商品（{sameRelease.length}件）</PanelTitle>
              <SameReleaseList items={sameRelease} from={from} />
            </Wide>
          )}
        </>
      )}
    </Layout>
  );
};
