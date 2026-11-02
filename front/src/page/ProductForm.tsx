import { useCallback, useEffect, useState } from 'react';
import { Link, useLocation, useParams } from 'react-router-dom';
import ReactLoading from 'react-loading';
import styled from 'styled-components';
import { Layout } from '../parts/Layout';
import {
  EDITABLE_KEYS,
  FormErrors,
  FormValues,
  Panel,
  PanelTitle,
  ProductFields,
  toFormValues,
} from '../parts/ProductFields';
import { SameReleaseList } from '../parts/SameReleaseList';
import { Button, PrimaryButton } from '../parts/ui';
import { api } from '../lib/api';
import { formatArtist, FromListState } from '../lib/format';
import { FilterOptions, ProductDetailResponse, SameReleaseItem } from '../types/product';

// 商品の詳細兼編集画面（docs/03-product-detail.md）。詳細と編集を別画面にせず、ここ1つで扱う。
//
// **保存 API は入力チェックだけ行い、まだ保存しない**（PATCH /api/products/:sku が persisted: false を返す）。
// CSV 出力のたびにスプレッドシートの値で products が上書きされるため、保存先が決まるまでは書き込まない。
//
// 本番で「保存できた」と誤解されないよう、編集は環境変数 REACT_APP_PRODUCT_EDIT=true のときだけ有効にする。
// 未設定なら従来どおり閲覧のみ。
const EDITABLE = process.env.REACT_APP_PRODUCT_EDIT === 'true';

const BackLink = styled(Link)`
  flex-shrink: 0;
  font-size: 14px;
  color: #3b5d8f;
  text-decoration: none;
  &:hover {
    text-decoration: underline;
  }
`;
// 「一覧に戻る」・SKU・在庫・アーティスト名と曲名を1行に並べる。狭い画面では折り返す
const Heading = styled.div`
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px 16px;
  margin-bottom: 16px;
`;
const SkuLine = styled.div`
  display: flex;
  align-items: center;
  gap: 12px;
  flex-shrink: 0;
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
  margin: 0;
  min-width: 0;
  font-size: 16px;
  color: #333;
`;
const Notice = styled.div`
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 4px 12px;
  margin: 0 0 16px;
  padding: 10px 14px;
  border-left: solid 4px #e0b44c;
  background-color: #fdf7e7;
  font-size: 13px;
  color: #6b5416;
  & > p {
    margin: 0;
  }
`;
// まだできていないこと・検討中のことは、注意書きが長くならないようツールチップに入れる。
// マウスを乗せるか、Tab でフォーカスすると開く
const TipWrap = styled.span`
  position: relative;
  &:hover > div,
  &:focus-within > div {
    display: block;
  }
`;
const TipTrigger = styled.button`
  padding: 0;
  border: none;
  background: none;
  font-size: 12px;
  color: #8a6d1d;
  text-decoration: underline dotted;
  cursor: help;
`;
const Tip = styled.div`
  display: none;
  position: absolute;
  top: 100%;
  left: 0;
  z-index: 3;
  width: min(520px, calc(100vw - 48px));
  margin-top: 6px;
  padding: 10px 14px;
  border: solid 1px #ddd;
  border-radius: 4px;
  background-color: #fff;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
  font-size: 12px;
  color: #333;
  & p {
    margin: 0;
    font-weight: bold;
  }
  & ul {
    margin: 4px 0 0;
    padding-left: 18px;
  }
  & ul + p {
    margin-top: 10px;
  }
`;

// 注意書きのツールチップに出す、まだできていないこと。実装したらここから消す。
// 先頭の「保存」だけは、編集できるか（EDITABLE）で文を変える
const NOT_YET = [
  EDITABLE
    ? '保存：「保存」を押しても入力内容のチェックだけで、DB にもスプレッドシートにも書き込みません'
    : '編集・保存：この画面ではまだ編集できません（保存先が決まっていないため）',
  'Discogs 読込：「読込」ボタンはまだ押せません',
  'SKU の変更：今後「SKU を変更」ボタンを別に設ける予定です。SKU は画像・試聴音源のファイル名や Shopify の Handle に使われているため、押すと影響を表示して確認を取り、変更先の SKU が重複していないかを確かめてから変えます',
];

// クライアントから依頼があり、作り方を検討中のこと（2026-11 の依頼ドキュメント）。決まったら NOT_YET に移す
const UNDER_CONSIDERATION = [
  'details 欄：新しい列「details」を追加し、各テンプレートの指定の場所に表示する',
  '説明文の入力補助：チェックボックスで定型文を選ぶと、日本語・英語の説明文に入るようにする',
  '英語の説明文：日本語の説明文から自動で翻訳して入れる',
  'weight：format を変えたときに、format に合わせた重さを自動で入れる',
  '入力候補：artist・label なども、過去の入力から候補を出す（今は country・format・sold_site・sales_status のみ）',
];
const Wide = styled(Panel)`
  margin-top: 16px;
`;
// 保存ボタンは長いフォームのどこからでも押せるよう、画面下に固定する
const ActionBar = styled.div`
  position: sticky;
  bottom: 0;
  z-index: 2;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  flex-wrap: wrap;
  gap: 12px;
  margin: 16px -24px -24px;
  padding: 12px 24px;
  border-top: solid 1px #ddd;
  background-color: rgba(255, 255, 255, 0.96);
`;
const Status = styled.p<{ $type: 'success' | 'error' | 'info' }>`
  margin: 0 auto 0 0;
  font-size: 13px;
  color: ${(p) => ({ success: '#1e6b3a', error: '#c0392b', info: '#777' })[p.$type]};
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

type Flash = { type: 'success' | 'error'; message: string } | null;

export const ProductForm = () => {
  const { sku = '' } = useParams();
  const location = useLocation();
  // 一覧から来たときは、検索条件ごと一覧に戻す。URL 直打ちなどで無ければ一覧の初期表示へ
  const from = (location.state as FromListState)?.from;
  const backTo = from || '/products';

  const [initialValues, setInitialValues] = useState<FormValues | null>(null);
  const [values, setValues] = useState<FormValues>({});
  const [errors, setErrors] = useState<FormErrors>({});
  const [options, setOptions] = useState<FilterOptions | null>(null);
  const [sameRelease, setSameRelease] = useState<SameReleaseItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [notFound, setNotFound] = useState(false);
  const [loadError, setLoadError] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [flash, setFlash] = useState<Flash>(null);

  // プルダウンの選択肢とジャンルマスタ。一覧の検索フォームと同じものを使う
  useEffect(() => {
    api
      .get<FilterOptions>('/api/products/filter_options')
      .then((res) => setOptions(res.data))
      .catch(() => setOptions(null)); // 取れなくても手入力はできるので握りつぶす
  }, []);

  useEffect(() => {
    let aborted = false;
    setIsLoading(true);
    setNotFound(false);
    setLoadError('');
    setErrors({});
    setFlash(null);
    api
      .get<ProductDetailResponse>(`/api/products/${encodeURIComponent(sku)}`)
      .then((res) => {
        if (aborted) return;
        const loaded = toFormValues(res.data.product);
        setInitialValues(loaded);
        setValues(loaded);
        setSameRelease(res.data.same_release);
      })
      .catch((e) => {
        if (aborted) return;
        setInitialValues(null);
        // 一覧へ自動で飛ばさない。打ち間違いか商品が消えたのかを利用者が判断できるよう、ここで伝える
        if (e.response?.status === 404) {
          setNotFound(true);
        } else {
          console.log('e', e);
          setLoadError('エラーが発生しました。岡本まで連絡してください');
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

  const changedKeys = initialValues
    ? EDITABLE_KEYS.filter((key) => (values[key] ?? '') !== (initialValues[key] ?? ''))
    : [];
  const isDirty = changedKeys.length > 0;

  // 未保存の変更があるままタブを閉じる・再読み込みするときに確認を出す
  useEffect(() => {
    if (!isDirty) return undefined;
    const warn = (event: BeforeUnloadEvent) => {
      event.preventDefault();
      event.returnValue = '';
    };
    window.addEventListener('beforeunload', warn);
    return () => window.removeEventListener('beforeunload', warn);
  }, [isDirty]);

  const handleChange = useCallback((key: string, value: string) => {
    setValues((current) => ({ ...current, [key]: value }));
    setFlash(null);
  }, []);

  const handleReset = () => {
    if (initialValues) setValues(initialValues);
    setErrors({});
    setFlash(null);
  };

  const handleSave = () => {
    if (!initialValues) return;
    // 変えた項目だけ送る。保存先がスプレッドシートになった場合も、触っていないセルを書き換えずに済む
    const payload = Object.fromEntries(changedKeys.map((key) => [key, values[key]]));
    setSubmitting(true);
    setErrors({});
    setFlash(null);
    api
      .patch(`/api/products/${encodeURIComponent(sku)}`, { product: payload })
      .then((res) => {
        if (res.data.persisted) {
          const saved = toFormValues(res.data.product);
          setInitialValues(saved);
          setValues(saved);
          setFlash({ type: 'success', message: '保存しました' });
        } else {
          setFlash({ type: 'success', message: '入力内容に問題はありません（まだ保存はされません）' });
        }
      })
      .catch((e) => {
        if (e.response?.status === 422) {
          setErrors(e.response.data.errors || {});
          setFlash({ type: 'error', message: '入力内容を確認してください' });
        } else {
          console.log('e', e);
          setFlash({ type: 'error', message: 'エラーが発生しました。岡本まで連絡してください' });
        }
      })
      .finally(() => setSubmitting(false));
  };

  const releaseId = initialValues?.discogs_release_id;
  const hasReleaseId = !!releaseId && releaseId !== '0';
  const quantity = initialValues?.quantity;

  return (
    <Layout>
      <Heading>
        <BackLink to={backTo}>← 一覧に戻る</BackLink>
        {!isLoading && initialValues && (
          <>
            <SkuLine>
              <Sku>SKU {initialValues.SKU}</Sku>
              {quantity !== '' && (
                <Badge $inStock={Number(quantity) >= 1}>{Number(quantity) >= 1 ? '在庫あり' : '在庫なし'}</Badge>
              )}
            </SkuLine>
            <Name>
              {[formatArtist(initialValues.artist), initialValues.title].filter((value) => value).join(' - ')}
            </Name>
          </>
        )}
      </Heading>

      {isLoading && (
        <Loading>
          <ReactLoading type="spinningBubbles" color="#b2cbf3" height="80px" width="80px" />
        </Loading>
      )}

      {!isLoading && notFound && <Message>SKU {sku} の商品は見つかりません</Message>}
      {!isLoading && loadError && <Message $error>{loadError}</Message>}

      {!isLoading && initialValues && (
        <>
          <Notice>
            <p>
              {EDITABLE ? '編集の確認用です。' : '現在は閲覧のみです。'}
              商品の修正はこれまでどおりスプレッドシートで行ってください。
            </p>
            <TipWrap>
              <TipTrigger type="button">未対応・検討中の機能</TipTrigger>
              <Tip role="tooltip">
                <p>まだできていないこと</p>
                <ul>
                  {NOT_YET.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
                <p>検討中のこと</p>
                <ul>
                  {UNDER_CONSIDERATION.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              </Tip>
            </TipWrap>
          </Notice>

          <ProductFields
            values={values}
            initialValues={initialValues}
            errors={errors}
            options={options}
            editable={EDITABLE}
            onChange={handleChange}
          />

          {hasReleaseId && (
            <Wide>
              <PanelTitle>同じ discogs_release_id の商品（{sameRelease.length}件）</PanelTitle>
              <SameReleaseList items={sameRelease} from={from} />
            </Wide>
          )}

          {EDITABLE && (
            <ActionBar>
              {flash ? (
                <Status $type={flash.type}>{flash.message}</Status>
              ) : (
                <Status $type="info">{isDirty ? `${changedKeys.length}項目を変更中` : '変更はありません'}</Status>
              )}
              <Button type="button" onClick={handleReset} disabled={!isDirty || submitting}>
                元に戻す
              </Button>
              <PrimaryButton type="button" onClick={handleSave} disabled={!isDirty || submitting}>
                {submitting ? '確認中…' : '保存'}
              </PrimaryButton>
            </ActionBar>
          )}
        </>
      )}
    </Layout>
  );
};
