import axios from 'axios';

export const Csv = () => {
  // const url = 'https://jsonplaceholder.typicode.com/posts/1'
  const getApi = () => {
    const url = 'http://localhost:3001/csv'
    const params = '?platform=discogs'
    axios.get(`${url}${params}`).then((res) => {
      console.log('res', res.data)
    })
  }
  return (
    <>
    <label for="country-select">国を選択</label>
    <select name="countries" id="country-select">
        <option value="">国</option>
        <option value="dog">japan</option>
        <option value="cat">海外</option>
    </select>
    <button
      onClick={getApi}
    >
      csvを出力
    </button>
    </>
  )
}