import { useCallback, useEffect, useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import ReactLoading from 'react-loading';
import styled from 'styled-components';
import { Layout } from '../parts/Layout';
import { Pagination } from '../parts/Pagination';
import { ProductSearchForm, SEARCH_KEYS, SearchValues } from '../parts/ProductSearchForm';
import { ProductTable } from '../parts/ProductTable';
import { api } from '../lib/api';
import { FilterOptions, Product, ProductListMeta } from '../types/product';
import { Select } from '../parts/ui';

const PER_PAGE_OPTIONS = [25, 50, 100];
const DEFAULT_PER_PAGE = 50;

const ResultHeader = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
  margin: 24px 0 12px;
`;
const Count = styled.p`
  margin: 0;
  font-size: 14px;
  color: #555;
`;
const Controls = styled.div`
  display: flex;
  align-items: center;
  gap: 12px;
`;
const PerPageSelect = styled(Select)`
  width: auto;
`;
const Footer = styled.div`
  display: flex;
  justify-content: flex-end;
  margin-top: 12px;
`;
const Loading = styled.div`
  display: flex;
  justify-content: center;
  padding: 60px;
`;
const ErrorText = styled.p`
  padding: 40px;
  text-align: center;
  color: #c0392b;
`;

export const ProductList = () => {
  // 検索条件・ページ・ソートはすべて URL に持たせる。
  // 戻る／進むが効き、URL をそのまま共有でき、リロードしても条件が消えない。
  const [searchParams, setSearchParams] = useSearchParams();

  const [products, setProducts] = useState<Product[]>([]);
  const [meta, setMeta] = useState<ProductListMeta | null>(null);
  const [options, setOptions] = useState<FilterOptions | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const queryString = searchParams.toString();

  const values: SearchValues = useMemo(() => {
    const result: SearchValues = {};
    SEARCH_KEYS.forEach((key) => {
      const value = searchParams.get(key);
      if (value) result[key] = value;
    });
    return result;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [queryString]);

  const perPage = Number(searchParams.get('per_page')) || DEFAULT_PER_PAGE;
  const sort = searchParams.get('sort') || 'SKU';
  const order = searchParams.get('order') === 'asc' ? 'asc' : 'desc';

  useEffect(() => {
    api
      .get<FilterOptions>('/api/products/filter_options')
      .then((res) => setOptions(res.data))
      .catch(() => setOptions(null)); // 選択肢が取れなくてもテキスト検索は使えるので握りつぶす
  }, []);

  useEffect(() => {
    let aborted = false;
    setIsLoading(true);
    setError('');
    api
      .get('/api/products', { params: Object.fromEntries(new URLSearchParams(queryString)) })
      .then((res) => {
        if (aborted) return;
        setProducts(res.data.products);
        setMeta(res.data.meta);
      })
      .catch((e) => {
        if (aborted) return;
        console.log('e', e);
        setError('商品の取得に失敗しました。時間をおいて再度お試しください。');
      })
      .finally(() => {
        if (!aborted) setIsLoading(false);
      });
    return () => {
      aborted = true;
    };
  }, [queryString]);

  // 条件を変えたら1ページ目に戻す。表示に関わらない既定値は URL に載せない
  const updateParams = useCallback(
    (next: { [key: string]: string | number }) => {
      const params = new URLSearchParams();
      Object.entries(next).forEach(([key, value]) => {
        if (value !== '' && value != null) params.set(key, String(value));
      });
      setSearchParams(params);
    },
    [setSearchParams],
  );

  const handleSearch = (nextValues: SearchValues) =>
    updateParams({
      ...nextValues,
      per_page: perPage === DEFAULT_PER_PAGE ? '' : perPage,
      sort: sort === 'SKU' ? '' : sort,
      order: order === 'desc' ? '' : order,
    });

  const handleClear = () => setSearchParams(new URLSearchParams());

  const handleSort = (column: string) => {
    // 同じ列を押したら昇順・降順を入れ替える。別の列なら降順から
    const nextOrder = sort === column && order === 'desc' ? 'asc' : 'desc';
    updateParams({
      ...values,
      per_page: perPage === DEFAULT_PER_PAGE ? '' : perPage,
      sort: column,
      order: nextOrder,
    });
  };

  const handlePerPage = (nextPerPage: number) =>
    updateParams({
      ...values,
      per_page: nextPerPage === DEFAULT_PER_PAGE ? '' : nextPerPage,
      sort: sort === 'SKU' ? '' : sort,
      order: order === 'desc' ? '' : order,
    });

  const handlePage = (nextPage: number) => {
    const params = new URLSearchParams(queryString);
    if (nextPage <= 1) {
      params.delete('page');
    } else {
      params.set('page', String(nextPage));
    }
    setSearchParams(params);
    window.scrollTo({ top: 0 });
  };

  const rangeText = () => {
    if (!meta || meta.total === 0) return '0件';
    const from = (meta.page - 1) * meta.per_page + 1;
    const to = Math.min(meta.page * meta.per_page, meta.total);
    return `${meta.total.toLocaleString()}件中 ${from.toLocaleString()}-${to.toLocaleString()}件を表示`;
  };

  return (
    <Layout back={{ to: '/', label: '戻る' }}>
      <h2>商品一覧</h2>

      <ProductSearchForm
        // クリア時にフォームの入力値も初期化するため、条件が変わったら作り直す
        key={queryString}
        values={values}
        options={options}
        onSearch={handleSearch}
        onClear={handleClear}
      />

      <ResultHeader>
        <Count>{rangeText()}</Count>
        <Controls>
          <PerPageSelect
            aria-label="表示件数"
            value={perPage}
            onChange={(e) => handlePerPage(Number(e.target.value))}
          >
            {PER_PAGE_OPTIONS.map((value) => (
              <option key={value} value={value}>
                {value}件
              </option>
            ))}
          </PerPageSelect>
          {meta && <Pagination page={meta.page} totalPages={meta.total_pages} onChange={handlePage} />}
        </Controls>
      </ResultHeader>

      {error && <ErrorText>{error}</ErrorText>}

      {isLoading ? (
        <Loading>
          <ReactLoading type="spinningBubbles" color="#b2cbf3" height="80px" width="80px" />
        </Loading>
      ) : (
        !error && (
          <>
            <ProductTable products={products} sort={sort} order={order} onSortChange={handleSort} />
            {meta && (
              <Footer>
                <Pagination page={meta.page} totalPages={meta.total_pages} onChange={handlePage} />
              </Footer>
            )}
          </>
        )
      )}
    </Layout>
  );
};
