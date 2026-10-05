import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { Csv } from './page/CsvCreate';
import { GenreList } from './page/GenreList';
import { Layout } from './parts/Layout';
import { ProductList } from './page/ProductList';
import { Top } from './page/Top';

export const App = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Top />} />
        <Route path="/products" element={<ProductList />} />
        <Route path="/genres" element={<GenreList />} />
        <Route
          path="/csv"
          element={
            <Layout>
              <Csv />
            </Layout>
          }
        />
      </Routes>
    </BrowserRouter>
  )
}
