import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { Csv } from './page/CsvCreate';
import { Layout } from './parts/Layout';
import { ProductList } from './page/ProductList';
import { Top } from './page/Top';

export const App = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Top />} />
        <Route path="/products" element={<ProductList />} />
        <Route
          path="/csv"
          element={
            <Layout back={{ to: '/', label: '戻る' }}>
              <Csv />
            </Layout>
          }
        />
      </Routes>
    </BrowserRouter>
  )
}
